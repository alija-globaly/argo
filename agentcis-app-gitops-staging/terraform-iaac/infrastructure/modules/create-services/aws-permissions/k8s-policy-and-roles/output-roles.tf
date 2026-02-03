# Policy Outputs
# ========================================
output "k8s_aws_load_balancer_controller_policy_id" {
  description = "The policy ID of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.main_aws_load_balancer_controller_policy.id
}

output "k8s_aws_load_balancer_controller_policy_arn" {
  description = "The ARN of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.main_aws_load_balancer_controller_policy.arn
}

output "k8s_aws_balancer_controller_policy_name" {
  description = "The name of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.main_aws_load_balancer_controller_policy.name
}

# Role Outputs
# ========================================
output "k8s_aws_balancer_controller_role_id" {
  description = "The ID of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.main_aws_load_balancer_controller_role.id
}

output "k8s_aws_load_balancer_controller_role_arn" {
  description = "The ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.main_aws_load_balancer_controller_role.arn
}

output "k8s_aws_load_balancer_controller_role_name" {
  description = "The name of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.main_aws_load_balancer_controller_role.name
}

output "k8s_aws_load_balancer_controller_role_unique_id" {
  description = "The unique ID assigned by AWS to the IAM role"
  value       = aws_iam_role.main_aws_load_balancer_controller_role.unique_id
}

# Instance Profile Outputs
# ========================================
output "k8s_aws_load_balancer_controller_instance_profile_id" {
  description = "The ID of the AWS Load Balancer Controller instance profile"
  value       = aws_iam_instance_profile.main_aws_load_balancer_controller_profile.id
}

output "k8s_aws_load_balancer_controller_instance_profile_arn" {
  description = "The ARN of the AWS Load Balancer Controller instance profile"
  value       = aws_iam_instance_profile.main_aws_load_balancer_controller_profile.arn
}

output "k8s_aws_load_balancer_controller_instance_profile_name" {
  description = "The name of the AWS Load Balancer Controller instance profile"
  value       = aws_iam_instance_profile.main_aws_load_balancer_controller_profile.name
}

output "k8s_aws_load_balancer_controller_instance_profile_unique_id" {
  description = "The unique ID assigned by AWS to the instance profile"
  value       = aws_iam_instance_profile.main_aws_load_balancer_controller_profile.unique_id
}
