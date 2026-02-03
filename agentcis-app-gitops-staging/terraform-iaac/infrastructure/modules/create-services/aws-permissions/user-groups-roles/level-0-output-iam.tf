################ 
output "iam_access_keys_policy_policy_id" {
  value       = aws_iam_policy.level_0_access_keys_policy.id
  description = "The policy's ID"
}

output "iam_access_keys_policy_policy_arn" {
  value       = aws_iam_policy.level_0_access_keys_policy.arn
  description = "The ARN of the policy"
}

output "iam_access_keys_policy_policy_name" {
  value       = aws_iam_policy.level_0_access_keys_policy.name
  description = "The name of the policy"
}