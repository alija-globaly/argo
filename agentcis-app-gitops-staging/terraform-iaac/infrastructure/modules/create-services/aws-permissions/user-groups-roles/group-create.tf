######### reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group


# Create IAM Group
resource "aws_iam_group" "main_group_create" {
  name = "${var.group_name}-${var.project_name}-${var.environment}"
  path = "/users/"
}

# Create IAM Users
resource "aws_iam_user" "main_users_create" {
  for_each = toset(var.user_name_list)

  name = each.value
  path = "/users/"

  tags = {
    Name    = each.value
    Group   = var.group_name
    project = var.project_name
  }
}

# Add Users to Group
resource "aws_iam_group_membership" "membership" {
  name = "${var.group_name}-membership"

  users = [
    for user in aws_iam_user.main_users_create : user.name
  ]

  group = aws_iam_group.main_group_create.name
}