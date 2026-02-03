###################### VPC outputs ###############
output "vpc-id" {
  value       = aws_vpc.main.id
  description = "My VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR block of the VPC"
}

output "vpc_dns_support" {
  value       = aws_vpc.main.enable_dns_support
  description = "Indicates whether DNS support is enabled"
}

output "vpc_dns_hostnames" {
  value       = aws_vpc.main.enable_dns_hostnames
  description = "Indicates whether DNS hostnames are enabled"
}

output "vpc_arn" {
  value       = aws_vpc.main.arn
  description = "ARN of the VPC"
}

############ internet gateway ##################
output "igw-id" {
  value       = aws_internet_gateway.gw.id
  description = "The ID of the Internet Gateway"
}

output "igw_arn" {
  value       = aws_internet_gateway.gw.arn
  description = "ARN of the Internet Gateway"
}
