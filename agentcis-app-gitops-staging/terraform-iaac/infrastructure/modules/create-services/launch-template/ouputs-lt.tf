# Outputs - Map format
output "launch_template_ids" {
  description = "Map of template name to ID"
  value       = { for k, v in aws_launch_template.main_launch_template_create : k => v.id }
}

output "launch_template_latest_versions" {
  description = "Map of template name to latest version"
  value       = { for k, v in aws_launch_template.main_launch_template_create : k => v.latest_version }
}

output "launch_template_default_versions" {
  description = "Map of template name to default version"
  value       = { for k, v in aws_launch_template.main_launch_template_create : k => v.default_version }
}

output "launch_template_names" {
  description = "Map of template name to full name"
  value       = { for k, v in aws_launch_template.main_launch_template_create : k => v.name }
}

output "launch_template_arns" {
  description = "Map of template name to ARN"
  value       = { for k, v in aws_launch_template.main_launch_template_create : k => v.arn }
}

output "launch_templates" {
  description = "Structured details of all launch templates"
  value = {
    for k, lt in aws_launch_template.main_launch_template_create : k => {
      id              = lt.id
      name            = lt.name
      arn             = lt.arn
      latest_version  = lt.latest_version
      default_version = lt.default_version
    }
  }
}

# Outputs - List format for backward compatibility
output "launch_template_ids_list" {
  description = "List of launch template IDs (ordered by launch_template_names)"
  value       = [for name in var.launch_template_names : aws_launch_template.main_launch_template_create[name].id]
}

output "launch_template_latest_versions_list" {
  description = "List of latest versions (ordered by launch_template_names)"
  value       = [for name in var.launch_template_names : aws_launch_template.main_launch_template_create[name].latest_version]
}

output "launch_template_default_versions_list" {
  description = "List of default versions (ordered by launch_template_names)"
  value       = [for name in var.launch_template_names : aws_launch_template.main_launch_template_create[name].default_version]
}

output "launch_templates_list" {
  description = "List of structured launch template details (ordered by launch_template_names)"
  value = [
    for name in var.launch_template_names : {
      id              = aws_launch_template.main_launch_template_create[name].id
      name            = aws_launch_template.main_launch_template_create[name].name
      arn             = aws_launch_template.main_launch_template_create[name].arn
      latest_version  = aws_launch_template.main_launch_template_create[name].latest_version
      default_version = aws_launch_template.main_launch_template_create[name].default_version
    }
  ]
}