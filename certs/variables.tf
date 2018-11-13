variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {}

variable "environment_type" {
  description = "environment"
}

variable "self_signed_ca_algorithm" {}

variable "self_signed_ca_rsa_bits" {
  default = 1024
}

variable "self_signed_ca_validity_period_hours" {}

variable "self_signed_ca_early_renewal_hours" {}

variable "is_ca_certificate" {
  default = false
}

variable depends_on {
  default = []
  type    = "list"
}