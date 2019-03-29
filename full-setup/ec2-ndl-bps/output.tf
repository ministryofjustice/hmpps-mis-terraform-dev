# primary ec2
output "primary_instance_id" {
  value = "${module.create-ec2-instance.instance_id}"
}

output "primary_private_ip" {
  value = "${module.create-ec2-instance.private_ip}"
}

# dns
output "primary_dns" {
  value = "${aws_route53_record.instance.fqdn}"
}

####################################################
# instance 2
####################################################

# secondary ec2
output "secondary_instance_id" {
  value = "${module.create-ec2-instance1.instance_id}"
}

output "secondary_private_ip" {
  value = "${module.create-ec2-instance1.private_ip}"
}

# dns
output "secondary_dns" {
  value = "${aws_route53_record.instance1.fqdn}"
}

####################################################
# instance 3
####################################################

# third ec2
output "third_instance_id" {
  value = "${module.create-ec2-instance2.instance_id}"
}

output "third_private_ip" {
  value = "${module.create-ec2-instance2.private_ip}"
}

# dns
output "third_dns" {
  value = "${aws_route53_record.instance2.fqdn}"
}
