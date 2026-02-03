resource "aws_route_table" "main_public_route_table" {
  vpc_id = data.aws_subnet.main_public[var.public_subnet_ids[0]].vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-route-table"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

resource "aws_route_table_association" "main_public_rt_associate" {
  for_each = toset(var.public_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.main_public_route_table.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.main_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id # You'll need to pass this as a variable
}
