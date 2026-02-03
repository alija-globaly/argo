variable "instance_id" {
  description = "EC2 instance ID to use for routing"
  type        = string
}

variable "route_table_id" {
  description = "Route table ID to add the route to"
  type        = string
  default     = ""
}

variable "k8s_pods_destination_cidr" {
  description = "Destination CIDR block for the route"
  type        = string
  default     = "10.1.0.0/16"
}
variable "network_interface_id" {
  description = "EC2 instance ID to use for routing"
  type        = string
}

