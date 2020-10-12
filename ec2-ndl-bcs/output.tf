output "bcs_instance_ids" {
  value = aws_instance.bcs_server.*.id
}

output "bcs_private_ips" {
  value = aws_instance.bcs_server.*.private_ip
}

# dns
output "bcs_primary_dns" {
  value = aws_route53_record.bcs_dns.*.fqdn
}

output "bcs_primary_dns_ext" {
  value = aws_route53_record.bcs_dns.*.fqdn
}

#bcs ami_id
output "bcs_ami_id" {
  value = aws_instance.bcs_server.*.ami
}

#bcs instance_type
output "bcs_instance_type" {
  value = aws_instance.bcs_server.*.instance_type
}

