resource "aws_backup_vault" "bcs_ec2_backup_vault" {
  name = "${var.environment_name}-bcs-ec2-bkup-pri-vlt"
  tags = "${merge(local.tags, map("Name", "${var.environment_name}-bcs-ec2-bkup-pri-vlt"))}"
}

resource "aws_backup_plan" "bcs_ec2_backup_plan" {
  name = "${var.environment_name}-bcs-ec2-bkup-pri-pln"

  rule {
    rule_name         = "MIS EC2 instance volume backup"
    target_vault_name = "${aws_backup_vault.bcs_ec2_backup_vault.name}"
    schedule          = "${var.ebs_backup["schedule"]}"

    lifecycle = {
      delete_after       = "${var.ebs_backup["delete_after"]}"
    }
  }

  tags = "${merge(local.tags, map("Name", "${var.environment_name}-bcs-ec2-bkup-pri-pln"))}"
}

resource "aws_backup_selection" "bcs_ec2_backup_selection" {
  iam_role_arn = "${data.terraform_remote_state.iam.mis_ec2_backup_role_arn}"
  name         = "${var.environment_name}-bcs-ec2-bkup-pri-sel"
  plan_id      = "${aws_backup_plan.bcs_ec2_backup_plan.id}"

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "${var.snap_tag}"
    value = "1"
  }
}
