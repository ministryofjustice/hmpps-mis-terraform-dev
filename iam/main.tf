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
### Getting the s3bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3buckets" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = "${var.region}"
  }
}

####################################################
# Locals
####################################################

locals {
  region                 = "${var.region}"
  app_name               = "${data.terraform_remote_state.common.mis_app_name}"
  environment_identifier = "${data.terraform_remote_state.common.environment_identifier}"
  tags                   = "${data.terraform_remote_state.common.common_tags}"
  s3-config-bucket       = "${data.terraform_remote_state.common.common_s3-config-bucket}"
  artefact-bucket        = "${data.terraform_remote_state.s3buckets.s3bucket}"
}

####################################################
# IAM - Application Specific
####################################################
module "iam" {
  source                   = "../modules/iam"
  app_name                 = "${local.app_name}"
  environment_identifier   = "${local.environment_identifier}"
  tags                     = "${local.tags}"
  ec2_role_policy_file     = "${file("../policies/ec2_role_policy.json")}"
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = "${file("../policies/ec2_internal_policy.json")}"
  s3-config-bucket         = "${local.s3-config-bucket}"
  artefact-bucket          = "${local.artefact-bucket}"
}
