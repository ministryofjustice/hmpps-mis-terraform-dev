variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "bcs_instance_type" {}

variable "bcs_root_size" {}

variable "bcs_server_count" {
  description = "Number of BCS Servers to deploy"
  default = 1
}
