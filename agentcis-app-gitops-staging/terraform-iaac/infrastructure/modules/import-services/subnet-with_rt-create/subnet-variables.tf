
# variable "vpc_id" {
#   type        = string
#   description = "VPC ID used to create subnet"
# }

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

variable "internet_gateway_id" {
  type        = string
  description = "Internet Gateway ID which the public route table will point to."
}

variable "subnet_availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

// tag variable
variable "project_name" {
  type        = string
  default     = "terraform-default"
  description = "Tag for project name"
}

variable "creator" {
  type        = string
  default     = "subash.chaudhary@globalyhub.com"
  description = "Tag for creator name"
}

variable "environment" {
  type        = string
  default     = "staging"
  description = "environment for  the product"
}