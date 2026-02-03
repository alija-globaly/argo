//vpc

############## common vairable ###############

variable "project_name" {
  type        = string
  default     = "devops-stage-deploy"
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


####################

variable "vpc_name" {
  type        = string
  default     = "devops-terraform"
  description = "Tag for project"
}

variable "cidr_block" {
  type        = string
  default     = "172.17.0.0/16"
  description = "CIDR bolck used for VPC"
}

// tags

variable "instance_tenancy" {
  type        = string
  description = "Tenancy option for instances launched inside the VPC"
  default     = "default"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Boolean value to enable/disable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Boolean value to enable/disable DNS support in the VPC"
  default     = true
}