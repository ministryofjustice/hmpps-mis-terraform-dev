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

####################################################
# Locals
####################################################

locals {
  region      = var.region
  common_name = data.terraform_remote_state.common.outputs.common_name
  tags        = data.terraform_remote_state.common.outputs.common_tags
}

####################################################
# S3 bucket - Application Specific
####################################################
module "s3bucket" {
  source      = "../modules/s3bucket"
  common_name = local.common_name
  tags        = local.tags
}

