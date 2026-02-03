data "aws_subnet" "main_public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}