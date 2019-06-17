terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 1.16"
}

#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = "${var.region}"
  }
}


####################################################
# Create SES domain
####################################################
resource "aws_ses_domain_identity" "mis_domain" {
  domain = "${data.terraform_remote_state.common.external_domain}"
}

####################################################
# Create Verification Records
####################################################
resource "aws_route53_record" "mis_amazonses_verification_record" {
  zone_id = "${data.terraform_remote_state.common.public_zone_id}"
  name    = "_amazonses.${data.terraform_remote_state.common.external_domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.mis_domain.verification_token}"]
}

resource "aws_ses_domain_identity_verification" "mis_verificatoin" {
  domain     = "${aws_ses_domain_identity.mis_domain.id}"

  depends_on = ["aws_route53_record.mis_amazonses_verification_record"]
}

####################################################
# Create DKIM records
####################################################

resource "aws_ses_domain_dkim" "mis_dkim_records" {
  domain     = "${aws_ses_domain_identity.mis_domain.domain}"
}

resource "aws_route53_record" "mis2_amazonses_verification_record" {
  count      = 3
  zone_id    = "${data.terraform_remote_state.common.public_zone_id}"
  name       = "${element(aws_ses_domain_dkim.mis_dkim_records.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.mis_domain.domain}"
  type       = "CNAME"
  ttl        = "600"
  records    = ["${element(aws_ses_domain_dkim.mis_dkim_records.dkim_tokens, count.index)}.dkim.amazonses.com"]
}


####################################################
# Create our sender ruleset and dns records
####################################################

resource "aws_ses_domain_mail_from" "mis_domain_from" {
  domain            = "${aws_ses_domain_identity.mis_domain.domain}"
  mail_from_domain  = "bounce.${aws_ses_domain_identity.mis_domain.domain}"
}

# Route53 MX record
resource "aws_route53_record" "mis_ses_domain_mail_from_mx" {
  zone_id   = "${data.terraform_remote_state.common.public_zone_id}"
  name      = "${aws_ses_domain_mail_from.mis_domain_from.mail_from_domain}"
  type      = "MX"
  ttl       = "600"
  records   = ["10 feedback-smtp.eu-west-1.amazonses.com"]
}

# Route53 TXT record for SPF
resource "aws_route53_record" "mis_ses_domain_mail_from_txt" {
  zone_id   = "${data.terraform_remote_state.common.public_zone_id}"
  name      = "${aws_ses_domain_mail_from.mis_domain_from.mail_from_domain}"
  type      = "TXT"
  ttl       = "600"
  records   = ["v=spf1 include:amazonses.com -all"]
}
