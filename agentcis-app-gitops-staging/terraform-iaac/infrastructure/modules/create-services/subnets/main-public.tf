############ reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "main_public_subnets" {
  count = length(var.public_subnet_cidr_blocks)

  cidr_block                          = var.public_subnet_cidr_blocks[count.index]
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = var.vpc_id
  availability_zone                   = element(var.subnet_availability_zones, count.index)

  tags = {
    Name        = "public-subnet-${var.project_name}-${var.environment}-${count.index + 1}"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

resource "aws_route_table" "main_public_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "public-route-table-${var.project_name}-${var.environment}"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "main_public_associate" {
  count          = length(aws_subnet.main_public_subnets)
  subnet_id      = aws_subnet.main_public_subnets[count.index].id
  route_table_id = aws_route_table.main_public_rt.id
}

resource "aws_route" "main_public_route" {
  route_table_id         = aws_route_table.main_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw-id
}

# resource "aws_route_table_association" "public_subnet_association" {
#   for_each       = aws_subnet.public_subnets
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.public.id
# }