######## reference records : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main_records" {
  count = length(var.subdomains)

  zone_id = aws_route53_zone.main_zone_private.zone_id
  name    = "${var.subdomains[count.index]}.${aws_route53_zone.main_zone_private.name}"
  type    = var.record_types[count.index]
  ttl     = var.dns_ttl
  records = [var.record_values[count.index]]
}