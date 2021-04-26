module "kms_key_misdsd_db" {
  source   = "../modules/keys/encryption_key"
  key_name = "${var.environment_type}-misdsd-db"
  tags = merge(
    local.tags,
    {
      "Name" = "${var.environment_type}-misdsd-db"
    },
  )
  environment_name = var.environment_name
}
