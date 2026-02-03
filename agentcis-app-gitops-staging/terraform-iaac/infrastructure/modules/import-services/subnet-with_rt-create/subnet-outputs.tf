output "private_subnet_ids" {
  description = "IDs of all private subnets"
  value       = [for subnet in data.aws_subnet.main_private : subnet.id]
}

output "private_subnet_arns" {
  description = "ARNs of all private subnets"
  value       = [for subnet in data.aws_subnet.main_private : subnet.arn]
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = [for subnet in data.aws_subnet.main_private : subnet.cidr_block]
}

output "private_subnet_azs" {
  description = "Availability zones of private subnets"
  value       = [for subnet in data.aws_subnet.main_private : subnet.availability_zone]
}

############### Public Subnet Outputs ####################
output "public_subnet_ids" {
  description = "IDs of all public subnets"
  value       = [for subnet in data.aws_subnet.main_public : subnet.id]
}

output "public_subnet_arns" {
  description = "ARNs of all public subnets"
  value       = [for subnet in data.aws_subnet.main_public : subnet.arn]
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = [for subnet in data.aws_subnet.main_public : subnet.cidr_block]
}

output "public_subnet_azs" {
  description = "Availability zones of public subnets"
  value       = [for subnet in data.aws_subnet.main_public : subnet.availability_zone]
}