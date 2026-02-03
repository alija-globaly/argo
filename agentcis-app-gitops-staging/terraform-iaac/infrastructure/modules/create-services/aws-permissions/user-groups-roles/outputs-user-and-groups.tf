output "group_name" {
  value       = aws_iam_group.main_group_create.name
  description = "Name of the IAM group"
}

output "group_arn" {
  value       = aws_iam_group.main_group_create.arn
  description = "ARN of the IAM group"
}

output "user_names" {
  value       = [for user in aws_iam_user.main_users_create : user.name]
  description = "List of created user names"
}

output "user_arns" {
  value       = { for k, user in aws_iam_user.main_users_create : k => user.arn }
  description = "Map of created user ARNs"
}