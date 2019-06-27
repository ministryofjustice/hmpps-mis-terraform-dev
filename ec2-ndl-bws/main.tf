terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting ACM Cert
#-------------------------------------------------------------
data "aws_acm_certificate" "cert" {
  domain      = "*.${data.terraform_remote_state.common.external_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

#-------------------------------------------------------------
### Getting the s3 details
#-------------------------------------------------------------
data "terraform_remote_state" "s3bucket" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the IAM details
#-------------------------------------------------------------
data "terraform_remote_state" "iam" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/iam/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the security groups details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS MIS NART BFS Windows Server master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

####################################################
# Locals
####################################################

locals {
  ami_id                       = "${data.aws_ami.amazon_ami.id}"
  account_id                   = "${data.terraform_remote_state.common.common_account_id}"
  vpc_id                       = "${data.terraform_remote_state.common.vpc_id}"
  cidr_block                   = "${data.terraform_remote_state.common.vpc_cidr_block}"
  allowed_cidr_block           = ["${data.terraform_remote_state.common.vpc_cidr_block}"]
  internal_domain              = "${data.terraform_remote_state.common.internal_domain}"
  private_zone_id              = "${data.terraform_remote_state.common.private_zone_id}"
  external_domain              = "${data.terraform_remote_state.common.external_domain}"
  public_zone_id               = "${data.terraform_remote_state.common.public_zone_id}"
  environment_identifier       = "${data.terraform_remote_state.common.environment_identifier}"
  short_environment_identifier = "${data.terraform_remote_state.common.short_environment_identifier}"
  region                       = "${var.region}"
  certificate_arn              = "${data.aws_acm_certificate.cert.arn}"
  app_name                     = "${data.terraform_remote_state.common.mis_app_name}"
  environment                  = "${data.terraform_remote_state.common.environment}"
  tags                         = "${data.terraform_remote_state.common.common_tags}"
  private_subnet_map           = "${data.terraform_remote_state.common.private_subnet_map}"
  s3bucket                     = "${data.terraform_remote_state.s3bucket.s3bucket}"
  logs_bucket                  = "${data.terraform_remote_state.common.common_s3_lb_logs_bucket}"
  app_hostnames                = "${data.terraform_remote_state.common.app_hostnames}"

  public_cidr_block  = ["${data.terraform_remote_state.common.db_cidr_block}"]
  public_subnet_ids  = ["${data.terraform_remote_state.common.public_subnet_ids}"]
  private_cidr_block = ["${data.terraform_remote_state.common.private_cidr_block}"]
  db_cidr_block      = ["${data.terraform_remote_state.common.db_cidr_block}"]
  sg_map_ids         = "${data.terraform_remote_state.security-groups.sg_map_ids}"
  instance_profile   = "${data.terraform_remote_state.iam.iam_policy_int_app_instance_profile_name}"
  ssh_deployer_key   = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
  nart_role          = "ndl-bws-${data.terraform_remote_state.common.legacy_environment_name}"
  sg_outbound_id     = "${data.terraform_remote_state.common.common_sg_outbound_id}"
  bws_port           = "${data.terraform_remote_state.security-groups.bws_port}"
}

#-------------------------------------------------------------
## Getting the admin username and password
#-------------------------------------------------------------
data "aws_ssm_parameter" "user" {
  name = "${local.environment_identifier}-${local.app_name}-admin-user"
}

data "aws_ssm_parameter" "password" {
  name = "${local.environment_identifier}-${local.app_name}-admin-password"
}

####################################################
# instance 1
####################################################

data "template_file" "instance_userdata" {
  template = "${file("../userdata/userdata.txt")}"

  vars {
    host_name       = "${local.nart_role}"
    internal_domain = "${local.internal_domain}"
    user            = "${data.aws_ssm_parameter.user.value}"
    password        = "${data.aws_ssm_parameter.password.value}"
  }
}

#-------------------------------------------------------------
### Create instance - NDL-BWS-300
#-------------------------------------------------------------
module "create-ec2-instance" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2_no_replace_instance"
  app_name                    = "${local.environment_identifier}-${local.app_name}-${local.nart_role}"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.bws_instance_type}"
  subnet_id                   = "${local.private_subnet_map["az1"]}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = "${data.template_file.instance_userdata.rendered}"
  CreateSnapshot              = false
  tags                        = "${local.tags}"
  key_name                    = "${local.ssh_deployer_key}"
  root_device_size            = "60"

  vpc_security_group_ids = [
    "${local.sg_map_ids["sg_mis_app_in"]}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_outbound_id}",
    "${local.sg_map_ids["sg_delius_db_out"]}"
  ]
}

#-------------------------------------------------------------
# Create route53 entry for instance 1
#-------------------------------------------------------------

resource "aws_route53_record" "instance" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.nart_role}.${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${module.create-ec2-instance.private_ip}"]
}

resource "aws_route53_record" "instance_ext" {
  zone_id = "${local.public_zone_id}"
  name    = "${local.nart_role}.${local.external_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${module.create-ec2-instance.private_ip}"]
}


####################################################
# instance 2
####################################################

data "template_file" "instance_secondary" {
  template = "${file("../userdata/userdata.txt")}"

  vars {
    host_name       = "${local.nart_role}-002"
    internal_domain = "${local.internal_domain}"
    user            = "${data.aws_ssm_parameter.user.value}"
    password        = "${data.aws_ssm_parameter.password.value}"
  }
}


#-------------------------------------------------------------
### Create instance - NDL-BWS-300-002
### Secondary instance
#-------------------------------------------------------------

resource "aws_instance" "instance" {
  ami                         = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.bws_instance_type}"
  subnet_id                   = "${local.private_subnet_map["az2"]}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${local.sg_map_ids["sg_mis_app_in"]}",
                                "${local.sg_map_ids["sg_mis_common"]}",
                                "${local.sg_outbound_id}",
                                "${local.sg_map_ids["sg_delius_db_out"]}"
                                ]
  user_data                   = "${data.template_file.instance_secondary.rendered}"
  key_name                    = "${local.ssh_deployer_key}"
  count                       = "${var.deploy_node}"

  tags = "${merge(
    local.tags,
    map("Name", "${local.environment_identifier}-${local.app_name}-${local.nart_role}-002"),
    map("CreateSnapshot", "false")
  )}"

  monitoring = true
  user_data  = "${data.template_file.instance_secondary.rendered}"

  root_block_device {
    volume_size = 60
  }

  lifecycle {
    ignore_changes = [
      "ami",
      "user_data"
    ]
  }
}

#-------------------------------------------------------------
# Create route53 entry for secondary instance
#-------------------------------------------------------------

resource "aws_route53_record" "secondary_instance" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.nart_role}-002.${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.instance.private_ip}"]
  count   = "${var.deploy_node}"
}

resource "aws_route53_record" "secondary_instance_ext" {
  zone_id = "${local.public_zone_id}"
  name    = "${local.nart_role}-002.${local.external_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.instance.private_ip}"]
  count   = "${var.deploy_node}"
}


#-------------------------------------------------------------
# Create elb attachment for secondary instance
#-------------------------------------------------------------

resource "aws_elb_attachment" "environment" {
  count     = "${var.deploy_node}"
  elb       = "${module.create_app_elb.environment_elb_name}"
  instance  = "${aws_instance.instance.id}"
}
