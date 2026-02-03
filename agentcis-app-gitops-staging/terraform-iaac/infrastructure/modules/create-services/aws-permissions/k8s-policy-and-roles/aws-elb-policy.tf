######### reference 1 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
#### refencr download policy : curl -o https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
resource "aws_iam_policy" "main_aws_load_balancer_controller_policy" {
  name        = "${var.project_name}-${var.environment}-K8s-AWSLoadBalancerController-policy"
  path        = "/"
  description = "IAM policy for AWS Load Balancer Controller to manage ALB/NLB resources"

  policy = file("${path.module}/aws-elb-policy-file.json")

  tags = {
    Name        = "${var.project_name}-${var.environment}-AWSLoadBalancerController-policy"
    creator     = var.creator
    environment = var.environment
    project     = var.project_name
  }
}