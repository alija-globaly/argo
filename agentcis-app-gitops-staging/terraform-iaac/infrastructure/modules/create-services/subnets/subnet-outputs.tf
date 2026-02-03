############### private subnet ####################
output "private_subnet_ids" {
  value = [for subnet in aws_subnet.main_private_subnets : subnet.id]
}

output "private_subnet_arns" {
  description = "ARNs of all private subnets"
  value       = [for subnet in aws_subnet.main_private_subnets : subnet.arn]
}

output "private_route_table_id" {
  value       = aws_route_table.main_private_rt.id
  description = "Private route table id"
}

output "private_route_table_arn" {
  description = "ARN of the private route table"
  value       = aws_route_table.main_private_rt.arn
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the created Private subnets"
  value       = [for subnet in aws_subnet.main_private_subnets : subnet.cidr_block]
}


############## public subnet output #############
output "public_subnet_ids" {
  value = [for subnet in aws_subnet.main_public_subnets : subnet.id] # Assuming your public subnets resource is named main_public_subnets
}

output "public_subnet_arns" {
  description = "ARNs of all public subnets"
  value       = [for subnet in aws_subnet.main_public_subnets : subnet.arn]
}

output "public_route_table_id" {
  value       = aws_route_table.main_public_rt.id # Assuming your public route table resource is named main_public_rt
  description = "Public route table id"
}


output "public_route_table_arn" {
  description = "ARN of the public route table"
  value       = aws_route_table.main_public_rt.arn
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the created Public subnets"
  value       = [for subnet in aws_subnet.main_public_subnets : subnet.cidr_block] # Adjust name if needed
}

