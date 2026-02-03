data "aws_subnet" "main_public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_route_table" "public" {
  for_each  = data.aws_subnet.main_public
  subnet_id = each.value.id
}
