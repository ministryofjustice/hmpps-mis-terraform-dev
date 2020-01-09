terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.17"
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

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting bws instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bws" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bws/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting dis instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-dis" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-dis/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting bps instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bps" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bps/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting bfs instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bfs" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bfs/terraform.tfstate"
    region = "${var.region}"
  }
}


#-------------------------------------------------------------
### Getting bcs instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bcs" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bcs/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting nextcloud details
#-------------------------------------------------------------
data "terraform_remote_state" "nextcloud" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/nextcloud/terraform.tfstate"
    region = "${var.region}"
  }
}


locals {
  environment_name             = "${var.environment_type}"
  environment_identifier       = "${data.terraform_remote_state.common.short_environment_identifier}"
  mis_app_name                 = "${data.terraform_remote_state.common.mis_app_name}"
  bws_lb_name                  = "${data.terraform_remote_state.ec2-ndl-bws.bws_elb_name}"
  nextcloud_lb_name            = "${data.terraform_remote_state.nextcloud.nextcloud_lb_name}"
  samba_lb_name                = "${data.terraform_remote_state.nextcloud.samba_lb_name}"
  log_group_name               = "/mis/application_logs"
  name_space                   = "LogMetrics"
}

#dashboard

resource "aws_cloudwatch_dashboard" "mis" {
  dashboard_name = "mis-${local.environment_name}-monitoring"
  dashboard_body = "${data.template_file.dashboard-body.rendered}"
}

data "template_file" "dashboard-body" {
  template = "${file("dashboard.json")}"
  vars {
    region            = "${var.region}"
    environment_name  = "${local.environment_name}"
    bws_lb_name       = "${local.bws_lb_name}"
    region            = "${var.region}"
    slow_latency      = 1
    nextcloud_lb_name = "${local.nextcloud_lb_name}"
  }
}


### SNS

resource "aws_sns_topic" "alarm_notification" {
  name               = "${local.mis_app_name}-alarm-notification"
}

resource "aws_sns_topic_subscription" "alarm_subscription" {
  count              = "${var.mis_alarms_enabled == "true" ? 1 : 0}"
  topic_arn          = "${aws_sns_topic.alarm_notification.arn}"
  protocol           = "lambda"
  endpoint           = "${aws_lambda_function.notify-ndmis-slack.arn}"
}

### Lambda

locals {
  lambda_name = "${local.mis_app_name}-notify-ndmis-slack"
}

data "archive_file" "notify-ndmis-slack" {
  type               = "zip"
  source_file        = "${path.module}/lambda/${local.lambda_name}.js"
  output_path        = "${path.module}/files/${local.lambda_name}zip"
}

data "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
}

resource "aws_lambda_function" "notify-ndmis-slack" {
  filename           = "${data.archive_file.notify-ndmis-slack.output_path}"
  function_name      = "${local.lambda_name}"
  role               = "${data.aws_iam_role.lambda_exec_role.arn}"
  handler            = "${local.lambda_name}.handler"
  source_code_hash   = "${base64sha256(file("${data.archive_file.notify-ndmis-slack.output_path}"))}"
  runtime            = "nodejs8.10"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id        = "AllowExecutionFromSNS"
  action              = "lambda:InvokeFunction"
  function_name       = "${aws_lambda_function.notify-ndmis-slack.arn}"
  principal           = "sns.amazonaws.com"
  source_arn          = "${aws_sns_topic.alarm_notification.arn}"
}
