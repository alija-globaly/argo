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

############## github #########
variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume this role"
  type        = list(string)
  default     = []
}