########## importing ############

variable "vpc-id" {
  description = "The ID of the existing VPC where the subnet will be created."
  default     = "vpc-088b623dd6702c325"
}

########## updating tags ##############
variable "project_name" {
  type        = string
  default     = "terraform-default"
  description = "Tag for project"
}

variable "vpc_name" {
  type        = string
  default     = "terraform"
  description = "Tag for project"
}

variable "creator" {
  type        = string
  default     = "subash.chaudhary@globalyhub.com"
  description = "Tag for project"
}

variable "environment" {
  type        = string
  default     = "staging"
  description = "environment for  the product"
}

########### internet gateway #################
variable "cidr_block" {
  type        = string
  default     = "172.17.0.0/16"
  description = "CIDR bolck used for VPC"
}