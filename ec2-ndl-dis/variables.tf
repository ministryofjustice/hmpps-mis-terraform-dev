variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "dis_instance_type" {}

variable "dis_root_size" {}

variable "dis_server_count" {
  description = "Number of DIS Servers to deploy"
  default = 1
}