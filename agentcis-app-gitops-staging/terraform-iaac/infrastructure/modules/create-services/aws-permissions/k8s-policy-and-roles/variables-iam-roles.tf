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