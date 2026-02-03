output "instance_id" {
  description = "Map of instance names to IDs"
  value       = { for k, v in aws_instance.ec2_instance : k => v.id }
}

output "ec2_public_dns_names" {
  description = "Map of instance names to public DNS names"
  value       = { for k, v in aws_instance.ec2_instance : k => v.public_dns }
}

output "public_ip_address" {
  description = "Map of instance names to public IPs"
  value       = { for k, v in aws_instance.ec2_instance : k => v.public_ip }
}

output "private_ip_address" {
  description = "Map of instance names to private IPs"
  value       = { for k, v in aws_instance.ec2_instance : k => v.private_ip }
}

# Optional: Also provide list outputs for backward compatibility
output "instance_id_list" {
  description = "List of instance IDs (ordered by instance_name)"
  value       = [for name in var.instance_name : aws_instance.ec2_instance[name].id]
}

output "public_ip_address_list" {
  description = "List of public IPs (ordered by instance_name)"
  value       = [for name in var.instance_name : aws_instance.ec2_instance[name].public_ip]
}

output "private_ip_address_list" {
  description = "List of private IPs (ordered by instance_name)"
  value       = [for name in var.instance_name : aws_instance.ec2_instance[name].private_ip]
}

###### network
output "primary_network_interface_id_list" {
  description = "List of primary network interface IDs (ordered by instance_name)"
  value       = [for name in var.instance_name : aws_instance.ec2_instance[name].primary_network_interface_id]
}

output "primary_network_interface_id" {
  description = "Map of instance names to primary network interface IDs"
  value       = { for k, v in aws_instance.ec2_instance : k => v.primary_network_interface_id }
}