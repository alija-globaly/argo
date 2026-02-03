output "route_id" {
  description = "The ID of the created route"
  value       = aws_route.instance_route.id
}

output "network_interface_id" {
  description = "Network interface ID used for routing"
  value       = var.network_interface_id
}

output "instance_id" {
  description = "Instance ID used for routing"
  value       = var.instance_id
}

output "route_table_id" {
  description = "Route table ID where the route was added"
  value       = var.route_table_id
}

output "destination_cidr_block" {
  description = "Destination CIDR block of the route"
  value       = var.k8s_pods_destination_cidr
}

output "route_state" {
  description = "State of the route"
  value       = aws_route.instance_route.state
}

output "route_origin" {
  description = "Origin of the route"
  value       = aws_route.instance_route.origin
}