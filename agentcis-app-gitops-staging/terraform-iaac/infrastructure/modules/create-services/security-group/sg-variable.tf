############ imported vairable ##########
variable "vpc_id" {
  type        = string
  description = "VPC ID used to create subnet"
}
############ common vairable ##############
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


variable "vpc_icmp_cidr" {
  type        = string
  default     = "172.34.0.0/16"
  description = "environment for  the product"
}
############# security group variable ###################
// security group
variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "devops-terraform"
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Allowing from outside"
}
// for ingress port, cidr etc
variable "sg_ingress_ports" {
  type        = list(string)
  description = "port of security group will be created"
}
variable "sg_ingress_cidrs" {
  type        = list(string)
  description = "cidr of security group will be created"
}
# variable "ingress_description" {
#   type = list(list(string))
#   description = "description of security group will be created"
# }