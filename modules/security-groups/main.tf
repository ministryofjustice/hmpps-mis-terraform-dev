####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################
locals {
  common_name        = "${var.environment_identifier}-${var.app_name}"
  vpc_id             = "${var.vpc_id}"
  allowed_cidr_block = ["${var.allowed_cidr_block}"]
  bastion_cidr       = ["${var.bastion_cidr}"]
  tags               = "${var.tags}"

  public_cidr_block = ["${var.public_cidr_block}"]

  private_cidr_block = ["${var.private_cidr_block}"]

  db_cidr_block = ["${var.db_cidr_block}"]
  sg_mis_app_in = "${var.sg_map_ids["sg_mis_app_in"]}"
  sg_mis_common = "${var.sg_map_ids["sg_mis_common"]}"
  sg_mis_db_in  = "${var.sg_map_ids["sg_mis_db_in"]}"
  sg_mis_app_lb = "${var.sg_map_ids["sg_mis_app_lb"]}"
  sg_ldap_lb    = "${var.sg_map_ids["sg_ldap_lb"]}"
  sg_ldap_inst  = "${var.sg_map_ids["sg_ldap_inst"]}"
}

#######################################
# SECURITY GROUPS
#######################################

#-------------------------------------------------------------
### app
#-------------------------------------------------------------

#-------------------------------------------------------------
### common sg rules
#-------------------------------------------------------------
resource "aws_security_group_rule" "rdp_in" {
  security_group_id = "${local.sg_mis_common}"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-rdp-in"

  cidr_blocks = [
    "${local.bastion_cidr}",
  ]
}

resource "aws_security_group_rule" "ssh_in" {
  security_group_id = "${local.sg_mis_common}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-rdp-in"

  cidr_blocks = [
    "${local.bastion_cidr}",
  ]
}

# ldap lb
resource "aws_security_group_rule" "lb_ldap_https" {
  security_group_id = "${local.sg_ldap_lb}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-ldap-https-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}

resource "aws_security_group_rule" "lb_ldap_http" {
  security_group_id = "${local.sg_ldap_lb}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-ldap-http-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}

# ldap inst
resource "aws_security_group_rule" "ldap_https_in" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-https-in"
  source_security_group_id = "${local.sg_ldap_lb}"
}

resource "aws_security_group_rule" "ldap_http_in" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-http-in"
  source_security_group_id = "${local.sg_ldap_lb}"
}

# app lb
resource "aws_security_group_rule" "lb_https_in" {
  security_group_id = "${local.sg_mis_app_lb}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-httpa-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}

# inst
resource "aws_security_group_rule" "http_alt_in" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-http-alt-in"
  source_security_group_id = "${local.sg_mis_app_lb}"
}

resource "aws_security_group_rule" "http_in" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-http-in"
  source_security_group_id = "${local.sg_mis_app_lb}"
}

# All local open
resource "aws_security_group_rule" "local_ingress" {
  security_group_id = "${local.sg_mis_common}"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_security_group_rule" "local_egress" {
  security_group_id = "${local.sg_mis_common}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}
