####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

############################################
# ADD TO KEY AND CSR
############################################
# KEY
module "server_key" {
  ###source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/tls/tls_private_key?ref=terraform-0.12"
  source    = "../temp_modules/tls_private_key"
  algorithm = var.self_signed_server_algorithm
  rsa_bits  = var.self_signed_server_rsa_bits
}

# csr
module "server_csr" {
  ####source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/tls/tls_cert_request?ref=terraform-0.12"
  source          = "../temp_modules/tls_cert_request"
  key_algorithm   = var.self_signed_server_algorithm
  private_key_pem = module.server_key.private_key
  subject         = local.server_subject
  dns_names       = local.server_dns_names
}

############################################
# SIGN CERT
############################################
# cert
module "server_cert" {
  ###source                = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/tls/tls_locally_signed_cert?ref=terraform-0.12"
  source                = "../temp_modules/tls_locally_signed_cert"
  cert_request_pem      = module.server_csr.cert_request_pem
  ca_key_algorithm      = var.self_signed_server_algorithm
  ca_private_key_pem    = module.ca_key.private_key
  ca_cert_pem           = module.ca_cert.cert_pem
  validity_period_hours = var.self_signed_server_validity_period_hours
  early_renewal_hours   = var.self_signed_server_early_renewal_hours

  allowed_uses = local.server_allowed_uses
}

############################################
# ADD TO IAM
############################################
# upload to IAM
module "iam_server_certificate" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam_certificate?ref=terraform-0.12"
  name_prefix       = "${local.internal_domain}-cert"
  certificate_body  = module.server_cert.cert_pem
  private_key       = module.server_key.private_key
  certificate_chain = module.ca_cert.cert_pem
  path              = "/${local.environment_identifier}/"
}

############################################
# ADD TO SSM
############################################
# CERT
module "create_parameter_cert" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ssm/parameter_store_file?ref=terraform-0.12"
  parameter_name = "${local.common_name}-self-signed-crt"
  description    = "${local.common_name}-self-signed-crt"
  type           = "String"
  value          = module.server_cert.cert_pem
  tags           = local.tags
}

module "create_parameter_key" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ssm/parameter_store_file?ref=terraform-0.12"
  parameter_name = "${local.common_name}-self-signed-private-key"
  description    = "${local.common_name}-self-signed-private-key"
  type           = "SecureString"
  value          = module.server_key.private_key
  tags           = local.tags
}
