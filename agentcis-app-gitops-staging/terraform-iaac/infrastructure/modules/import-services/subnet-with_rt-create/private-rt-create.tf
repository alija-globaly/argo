resource "aws_route_table" "main_private_route_table" {
  vpc_id = data.aws_subnet.main_private[var.private_subnet_ids[0]].vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-route-table"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

resource "aws_route_table_association" "main_private_rt_associate" {
  for_each = toset(var.private_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.main_private_route_table.id
}
