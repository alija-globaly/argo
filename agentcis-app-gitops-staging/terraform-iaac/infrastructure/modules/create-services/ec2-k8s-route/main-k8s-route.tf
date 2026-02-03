
resource "aws_route" "instance_route" {
  route_table_id         = var.route_table_id
  destination_cidr_block = var.k8s_pods_destination_cidr
  network_interface_id   = var.network_interface_id
}
