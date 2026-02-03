##################### Resource Import variable ###################
variable "vpc-id" {
  description = "The ID of the existing VPC where the subnet will be created."
  default     = "vpc-088b623dd6702c325"
}

########## subnets ##########
variable "subnet_availability_zones" {
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  description = "List of availability zones"
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = ["subnet-0da79630200049eac", "subnet-0d2f982bd7171b329", "subnet-0f7fb9330d181fb68"]
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = ["subnet-0da11260c7546ab19", "subnet-0a501d6e0f51df9c9", "subnet-0c6b80c00b45454f2"]
  description = "List of private subnet IDs"
}