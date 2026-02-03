################# reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
################# reference 2 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway.html
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name        = "${var.project_name}-${var.vpc_name}-${var.environment}-VPC"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment

  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.vpc_name}-${var.environment}-igw"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}