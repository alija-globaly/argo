############# reference 1: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
############# reference 2: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
data "aws_subnet" "main_private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}



