############ zones ##############
output "private_hosted_zone_id" {
  description = "Route53 private hosted zone ID"
  value       = aws_route53_zone.main_zone_private.zone_id
}

output "private_hosted_zone_arn" {
  description = "ARN of the private Route53 hosted zone"
  value       = aws_route53_zone.main_zone_private.arn
}

########### records ################
output "dns_record_fqdns" {
  description = "Fully qualified DNS record names created in the private zone"
  value = [
    for r in aws_route53_record.main_records : r.fqdn
  ]
}

output "dns_record_types" {
  description = "DNS record types created"
  value = [
    for r in aws_route53_record.main_records : r.type
  ]
}

output "dns_record_values" {
  description = "DNS record values"
  value = flatten([
    for r in aws_route53_record.main_records : r.records
  ])
}

