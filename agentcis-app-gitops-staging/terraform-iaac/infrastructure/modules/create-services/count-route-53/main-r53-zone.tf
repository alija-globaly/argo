############## reference 1 zone: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
############## reference 2 record: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record

resource "aws_route53_zone" "main_zone_private" {
  name    = "${var.domain_name}-${var.environment}.internal"
  comment = "Private hosted zone for ${var.domain_name} - managed by Terraform"

  # VPC association - this makes it a private zone
  vpc {
    vpc_id = var.vpc-id
  }

  tags = {
    Name        = var.domain_name
    environment = var.environment
    project     = var.project_name
  }

  # Lifecycle to prevent accidental deletion
  lifecycle {
    prevent_destroy = false # Set to true in production
  }
}