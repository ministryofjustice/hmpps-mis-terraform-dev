module "mis_db_3" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//oracle-database"
  server_name = "mis-db-3"

  ami_id               = "${data.aws_ami.centos_oracle_db.id}"
  db_subnet            = "${data.terraform_remote_state.vpc.vpc_db-subnet-az3}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.iam.iam_policy_int_app_instance_profile_name}"

  security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.security-groups.sg_map_ids["sg_mis_app_in"]}",
    "${data.terraform_remote_state.security-groups.sg_map_ids["sg_mis_common"]}",
    "${data.terraform_remote_state.common.common_sg_outbound_id}",
  ]

  tags                         = "${var.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"

  environment_type = "${var.environment_type}"
  region           = "${var.region}"

  kms_key_id      = "${module.kms_key_mis_db.kms_arn}"
  public_zone_id  = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
  private_domain  = "${data.terraform_remote_state.vpc.private_zone_name}"
  vpc_account_id  = "${data.terraform_remote_state.vpc.vpc_account_id}"
  db_size         = "${var.db_size_mis}"

  ansible_vars = {
    service_user_name             = "${var.ansible_vars_mis_db["service_user_name"]}"
    database_global_database_name = "${var.ansible_vars_mis_db["database_global_database_name"]}"
    database_sid                  = "${var.ansible_vars_mis_db["database_sid"]}"
    database_characterset         = "${var.ansible_vars_mis_db["database_characterset"]}"
    oracle_dbca_template_file     = "${var.ansible_vars_mis_db["oracle_dbca_template_file"]}"
    database_type                 = "standby" # required for the DB module. This file is where the property is set.

    ## the following are retrieved from SSM Parameter Store
    ## oradb_sys_password            = "/${environment_name}/mis/mis-database/db/oradb_sys_password"
    ## oradb_system_password         = "/${environment_name}/mis/mis-database/db/oradb_system_password"
    ## oradb_sysman_password         = "/${environment_name}/mis/mis-database/db/oradb_sysman_password"
    ## oradb_dbsnmp_password         = "/${environment_name}/mis/mis-database/db/oradb_dbsnmp_password"
    ## oradb_asmsnmp_password        = "/${environment_name}/mis/mis-database/db/oradb_asmsnmp_password"
  }
}

output "ami_mis_db_3" {
  value = "${module.mis_db_3.ami_id}"
}

output "public_fqdn_mis_db_3" {
  value = "${module.mis_db_3.public_fqdn}"
}

output "internal_fqdn_mis_db_3" {
  value = "${module.mis_db_3.internal_fqdn}"
}

output "private_ip_mis_db_3" {
  value = "${module.mis_db_3.private_ip}"
}

output "db_disks_mis_db_3" {
  value = "${module.mis_db_3.db_size_parameters}"
}
