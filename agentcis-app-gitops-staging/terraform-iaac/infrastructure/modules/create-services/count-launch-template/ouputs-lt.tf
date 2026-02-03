output "launch_template_ids" {
  description = "List of AWS Launch Template IDs"
  value       = aws_launch_template.main_launch_template_create[*].id
}

output "launch_template_latest_versions" {
  description = "Latest version numbers of the AWS Launch Templates"
  value       = aws_launch_template.main_launch_template_create[*].latest_version
}

output "launch_template_default_versions" {
  description = "Default version numbers of the AWS Launch Templates"
  value       = aws_launch_template.main_launch_template_create[*].default_version
}

output "launch_template_names" {
  description = "Names of the AWS Launch Templates"
  value       = aws_launch_template.main_launch_template_create[*].name
}

output "launch_template_arns" {
  description = "ARNs of the AWS Launch Templates"
  value       = aws_launch_template.main_launch_template_create[*].arn
}

output "launch_templates" {
  description = "Structured details of all launch templates"
  value = [
    for lt in aws_launch_template.main_launch_template_create : {
      id              = lt.id
      name            = lt.name
      arn             = lt.arn
      latest_version  = lt.latest_version
      default_version = lt.default_version
    }
  ]
}
