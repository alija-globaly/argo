##### github actions role output ###############
output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = aws_iam_role.main_github_actions_role.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.main_github_actions_role.name
}

output "github_actions_role_id" {
  description = "Unique ID of the GitHub Actions IAM role"
  value       = aws_iam_role.main_github_actions_role.id
}

output "github_actions_role_unique_id" {
  description = "Stable and unique string identifying the role"
  value       = aws_iam_role.main_github_actions_role.unique_id
}


############# github output repositories ####################
output "authorized_github_repositories" {
  description = "List of GitHub repositories authorized to assume this role"
  value       = var.github_repositories
}

output "github_repositories_with_prefix" {
  description = "Full repository identifiers with repo: prefix as used in the assume role policy"
  value       = [for repo in var.github_repositories : "repo:${repo}:*"]
}
