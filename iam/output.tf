####################################################
# IAM - Application specific
####################################################

# APP ROLE
output "iam_policy_int_app_role_name" {
  value = "${module.iam.iam_policy_int_app_role_name}"
}

output "iam_policy_int_app_role_arn" {
  value = "${module.iam.iam_policy_int_app_role_arn}"
}

# PROFILE
output "iam_policy_int_app_instance_profile_name" {
  value = "${module.iam.iam_policy_int_app_instance_profile_name}"
}

# jump host
output "iam_policy_int_jumphost_role_name" {
  value = "${module.jumphost.iam_policy_int_app_role_name}"
}

output "iam_policy_int_jumphost_role_arn" {
  value = "${module.jumphost.iam_policy_int_app_role_arn}"
}

# PROFILE
output "iam_policy_int_jumphost_instance_profile_name" {
  value = "${module.jumphost.iam_policy_int_app_instance_profile_name}"
}
