############ reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "main_private_subnets" {
  count = length(var.private_subnet_cidr_blocks)

  cidr_block                          = var.private_subnet_cidr_blocks[count.index]
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = var.vpc_id
  availability_zone                   = element(var.subnet_availability_zones, count.index)

  tags = {
    Name        = "private-subnet-${var.project_name}-${var.environment}-${count.index + 1}"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

resource "aws_route_table" "main_private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "private-route-table-${var.project_name}-${var.environment}"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "main_private_associate" {
  count          = length(aws_subnet.main_private_subnets)
  subnet_id      = aws_subnet.main_private_subnets[count.index].id
  route_table_id = aws_route_table.main_private_rt.id
}

############ disabling route from connecting to public ####################

# resource "aws_route" "main_private_route" {
#   route_table_id         = aws_route_table.main_private_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = var.igw-id 
# }
