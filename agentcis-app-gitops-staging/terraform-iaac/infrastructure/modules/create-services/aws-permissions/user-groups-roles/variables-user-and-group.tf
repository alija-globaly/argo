################# common variable
variable "project_name" {
  type        = string
  default     = "terraform-default"
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


# Variables
variable "group_name" {
  description = "Name of the IAM group"
  type        = string
}

variable "user_name_list" {
  description = "List of IAM user names"
  type        = list(string)
}
