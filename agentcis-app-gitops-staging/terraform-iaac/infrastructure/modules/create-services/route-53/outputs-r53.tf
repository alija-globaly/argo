# Outputs - Zone
output "private_hosted_zone_id" {
  description = "Route53 private hosted zone ID"
  value       = aws_route53_zone.main_zone_private.zone_id
}

output "private_hosted_zone_arn" {
  description = "ARN of the private Route53 hosted zone"
  value       = aws_route53_zone.main_zone_private.arn
}

output "private_hosted_zone_name" {
  description = "Name of the private Route53 hosted zone"
  value       = aws_route53_zone.main_zone_private.name
}

# Outputs - Records (Map format)
output "dns_record_fqdns" {
  description = "Map of subdomain to FQDN"
  value = {
    for subdomain, record in aws_route53_record.main_records : subdomain => record.fqdn
  }
}

output "dns_record_types" {
  description = "Map of subdomain to record type"
  value = {
    for subdomain, record in aws_route53_record.main_records : subdomain => record.type
  }
}

output "dns_record_values" {
  description = "Map of subdomain to record values"
  value = {
    for subdomain, record in aws_route53_record.main_records : subdomain => record.records
  }
}

# Outputs - Records (List format for backward compatibility)
output "dns_record_fqdns_list" {
  description = "List of FQDNs (ordered by subdomains variable)"
  value = [
    for subdomain in var.subdomains : aws_route53_record.main_records[subdomain].fqdn
  ]
}

output "dns_record_types_list" {
  description = "List of record types (ordered by subdomains variable)"
  value = [
    for subdomain in var.subdomains : aws_route53_record.main_records[subdomain].type
  ]
}

output "dns_record_values_list" {
  description = "List of record values (ordered by subdomains variable)"
  value = flatten([
    for subdomain in var.subdomains : aws_route53_record.main_records[subdomain].records
  ])
}