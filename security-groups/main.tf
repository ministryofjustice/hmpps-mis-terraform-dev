terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sg details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the delius core security groups
#-------------------------------------------------------------
data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the Nat gateway details
#-------------------------------------------------------------
data "terraform_remote_state" "natgateway" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "natgateway/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the Code Build CI Details
#-------------------------------------------------------------
data "terraform_remote_state" "codebuild" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-pipelines/components/mis/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the bastion details
#-------------------------------------------------------------
data "terraform_remote_state" "bastion" {
  backend = "s3"

  config = {
    bucket   = var.bastion_remote_state_bucket_name
    key      = "service-bastion/terraform.tfstate"
    region   = var.region
    role_arn = var.bastion_role_arn
  }
}

####################################################
# Locals
####################################################

locals {
  vpc_id                      = data.terraform_remote_state.common.outputs.vpc_id
  cidr_block                  = data.terraform_remote_state.common.outputs.vpc_cidr_block
  user_access_cidr_blocks     = flatten(var.user_access_cidr_blocks)
  env_user_access_cidr_blocks = flatten(var.env_user_access_cidr_blocks)
  bastion_cidr                = flatten(data.terraform_remote_state.common.outputs.bastion_cidr)
  common_name                 = data.terraform_remote_state.common.outputs.common_name
  region                      = data.terraform_remote_state.common.outputs.region
  app_name                    = data.terraform_remote_state.common.outputs.mis_app_name
  environment_identifier      = data.terraform_remote_state.common.outputs.environment_identifier
  environment                 = data.terraform_remote_state.common.outputs.environment
  tags                        = data.terraform_remote_state.common.outputs.common_tags
  public_cidr_block           = [data.terraform_remote_state.common.outputs.db_cidr_block]
  private_cidr_block          = [data.terraform_remote_state.common.outputs.private_cidr_block]
  db_cidr_block               = [data.terraform_remote_state.common.outputs.db_cidr_block]
  bws_port                    = var.bws_port
  sg_outbound_id              = data.terraform_remote_state.common.outputs.common_sg_outbound_id
  natgateway_az1              = ["${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az1}/32"]
  natgateway_az2              = ["${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az2}/32"]
  natgateway_az3              = ["${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az3}/32"]
  bastion_public_ip           = ["${data.terraform_remote_state.bastion.outputs.bastion_ip}/32"]

  sg_map_ids = {
    sg_mis_db_in     = data.terraform_remote_state.security-groups.outputs.sg_mis_db_in
    sg_mis_common    = data.terraform_remote_state.security-groups.outputs.sg_mis_common
    sg_mis_app_in    = data.terraform_remote_state.security-groups.outputs.sg_mis_app_in
    sg_mis_app_lb    = data.terraform_remote_state.security-groups.outputs.sg_mis_app_lb
    sg_ldap_lb       = data.terraform_remote_state.security-groups.outputs.sg_ldap_lb
    sg_ldap_inst     = data.terraform_remote_state.security-groups.outputs.sg_ldap_inst
    sg_ldap_proxy    = data.terraform_remote_state.security-groups.outputs.sg_ldap_proxy
    sg_jumphost      = data.terraform_remote_state.security-groups.outputs.sg_jumphost
    sg_delius_db_out = data.terraform_remote_state.security-groups.outputs.sg_mis_out_to_delius_db_id
  }
}

locals {
  sg_mis_common = local.sg_map_ids["sg_mis_common"]
  sg_jumphost   = local.sg_map_ids["sg_jumphost"]
  sg_mis_app_lb = local.sg_map_ids["sg_mis_app_lb"]
  sg_ldap_inst  = local.sg_map_ids["sg_ldap_inst"]
  sg_ldap_proxy = local.sg_map_ids["sg_ldap_proxy"]
  sg_ldap_lb    = local.sg_map_ids["sg_ldap_lb"]
  sg_mis_db_in  = local.sg_map_ids["sg_mis_db_in"]
  sg_mis_app_in = local.sg_map_ids["sg_mis_app_in"]
}
