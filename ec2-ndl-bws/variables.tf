variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {
}

variable "bws_instance_type" {
}

# LB
variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 1800
}

variable "connection_draining" {
  description = "Boolean to enable connection draining"
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  default     = 300
}

variable "bws-listener" {
  description = "A list of listener blocks"
  type        = list(string)
  default     = []
}

variable "access_logs" {
  description = "An access logs block"
  type        = list(string)
  default     = []
}

variable "bws-health_check" {
  description = "A health check block"
  type        = list(string)
  default     = []
}

variable "bws_root_size" {
}

variable "bws_server_count" {
  description = "Number of BWS Servers to deploy"
  default     = 1
}

variable "ebs_backup" {
  type = map(string)

  default = {
    schedule     = "cron(0 01 * * ? *)"
    delete_after = 15
  }
}

variable "environment_name" {
  type = string
}

variable "snap_tag" {
  default = "CreateSnapshotBWS"
}

variable "bws_disable_api_termination" {
  type = bool
}

variable "bws_ebs_optimized" {
  type = bool
}

variable "bws_hibernation" {
  type = bool
}
