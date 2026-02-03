######## reference records : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
locals {
  dns_records_map = {
    for idx, subdomain in var.subdomains : subdomain => {
      record_type  = var.record_types[idx]
      record_value = var.record_values[idx]
    }
  }
}

resource "aws_route53_record" "main_records" {
  for_each = local.dns_records_map

  zone_id = aws_route53_zone.main_zone_private.zone_id
  name    = "${each.key}.${aws_route53_zone.main_zone_private.name}"
  type    = each.value.record_type
  ttl     = var.dns_ttl
  records = [each.value.record_value]
}