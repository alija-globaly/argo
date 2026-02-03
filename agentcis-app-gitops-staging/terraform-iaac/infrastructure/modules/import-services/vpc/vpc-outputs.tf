###################### VPC outputs ###############
output "vpc-id" {
  value       = data.aws_vpc.existing_vpc.id
  description = "Imported VPC ID"
}

output "vpc_cidr_block" {
  value       = data.aws_vpc.existing_vpc.cidr_block
  description = "CIDR block of the imported VPC"
}

output "vpc_dns_support" {
  value       = data.aws_vpc.existing_vpc.enable_dns_support
  description = "Indicates whether DNS support is enabled"
}

output "vpc_dns_hostnames" {
  value       = data.aws_vpc.existing_vpc.enable_dns_hostnames
  description = "Indicates whether DNS hostnames are enabled"
}

output "vpc_arn" {
  value       = data.aws_vpc.existing_vpc.arn
  description = "ARN of the imported VPC"
}
#################### vpc gateway ########################
############ internet gateway ##################
# output "igw-id" {
#   value       = aws_internet_gateway.gw.id
#   description = "The ID of the Internet Gateway"
# }

# output "igw_arn" {
#   value       = aws_internet_gateway.gw.arn
#   description = "ARN of the Internet Gateway"
# }

output "igw-id" {
  value       = data.aws_internet_gateway.existing_igw.id
  description = "ID of the Internet Gateway attached to the VPC"
}

output "igw-arn" {
  value       = data.aws_internet_gateway.existing_igw.arn
  description = "ARN of the Internet Gateway"
}
