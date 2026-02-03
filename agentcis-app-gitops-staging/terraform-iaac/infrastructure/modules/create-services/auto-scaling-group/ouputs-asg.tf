# Outputs - Map format
output "asg_ids" {
  description = "Map of ASG name to ID"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.id }
}

output "asg_arns" {
  description = "Map of ASG name to ARN"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.arn }
}

output "asg_names" {
  description = "Map of ASG name to full resource name"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.name }
}

output "asg_desired_capacities" {
  description = "Map of ASG name to desired capacity"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.desired_capacity }
}

output "asg_min_sizes" {
  description = "Map of ASG name to minimum size"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.min_size }
}

output "asg_max_sizes" {
  description = "Map of ASG name to maximum size"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.max_size }
}

output "asg_availability_zones" {
  description = "Map of ASG name to availability zones"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.availability_zones }
}

output "asg_vpc_zone_identifiers" {
  description = "Map of ASG name to VPC zone identifiers (subnets)"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.vpc_zone_identifier }
}

output "asg_health_check_types" {
  description = "Map of ASG name to health check type"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.health_check_type }
}

output "asg_target_group_arns" {
  description = "Map of ASG name to target group ARNs"
  value       = { for k, v in aws_autoscaling_group.autoscaling_group : k => v.target_group_arns }
}

output "asg_details" {
  description = "Structured details of all Auto Scaling Groups"
  value = {
    for k, asg in aws_autoscaling_group.autoscaling_group : k => {
      id                  = asg.id
      arn                 = asg.arn
      name                = asg.name
      desired_capacity    = asg.desired_capacity
      min_size            = asg.min_size
      max_size            = asg.max_size
      availability_zones  = asg.availability_zones
      vpc_zone_identifier = asg.vpc_zone_identifier
      health_check_type   = asg.health_check_type
      target_group_arns   = asg.target_group_arns
    }
  }
}

# Outputs - List format for backward compatibility
output "asg_ids_list" {
  description = "List of ASG IDs (ordered by asg_names)"
  value       = [for name in var.asg_names : aws_autoscaling_group.autoscaling_group[name].id]
}

output "asg_arns_list" {
  description = "List of ASG ARNs (ordered by asg_names)"
  value       = [for name in var.asg_names : aws_autoscaling_group.autoscaling_group[name].arn]
}

output "asg_names_list" {
  description = "List of ASG names (ordered by asg_names)"
  value       = [for name in var.asg_names : aws_autoscaling_group.autoscaling_group[name].name]
}

output "asg_details_list" {
  description = "List of structured ASG details (ordered by asg_names)"
  value = [
    for name in var.asg_names : {
      id                  = aws_autoscaling_group.autoscaling_group[name].id
      arn                 = aws_autoscaling_group.autoscaling_group[name].arn
      name                = aws_autoscaling_group.autoscaling_group[name].name
      desired_capacity    = aws_autoscaling_group.autoscaling_group[name].desired_capacity
      min_size            = aws_autoscaling_group.autoscaling_group[name].min_size
      max_size            = aws_autoscaling_group.autoscaling_group[name].max_size
      availability_zones  = aws_autoscaling_group.autoscaling_group[name].availability_zones
      vpc_zone_identifier = aws_autoscaling_group.autoscaling_group[name].vpc_zone_identifier
      health_check_type   = aws_autoscaling_group.autoscaling_group[name].health_check_type
      target_group_arns   = aws_autoscaling_group.autoscaling_group[name].target_group_arns
    }
  ]
}