############ imported vairable ##########
variable "vpc_id" {
  type        = string
  description = "VPC ID used to create subnet"
}

variable "igw-id" {
  type        = string
  description = "Internet Gateway ID which the public route table will point to."
}

############ common vairable ##############
variable "subnet_availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "project_name" {
  type        = string
  default     = "devops-terraform"
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

############ private subnet variable #############
variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
}
############ public subnet variable #############
variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}
