# Attach the AWS Load Balancer Controller policy to the role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attachment" {
  role       = aws_iam_role.main_aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.main_aws_load_balancer_controller_policy.arn # Changed from _role to _policy
}

# # Attach the comprehensive policy to your existing role
resource "aws_iam_role_policy_attachment" "k8s_ecr_policy_attachment" {
  role       = aws_iam_role.main_aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.main_aws_ecr_allow_policy.arn
}