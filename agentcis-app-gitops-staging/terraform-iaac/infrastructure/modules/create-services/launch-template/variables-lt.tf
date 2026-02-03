// template
######################## common variable and tags ###############
variable "creator" {
  type        = string
  default     = "subash.chaudhary@globalyhub.com"
  description = "Tag for project"
}

variable "project_name" {
  type        = string
  default     = "terraform-default"
  description = "Tag for project"
}

variable "environment" {
  type        = string
  default     = "staging"
  description = "enviorment for  the product"
}

#################################


variable "launch_template_names" {
  type        = list(string)
  description = "List of launch template names"
  default     = ["terraform-default"]
}
variable "launch_template_ami_ids" {
  type        = list(string)
  description = "List of AMI IDs for each launch template"
  default     = ["ami-060e277c0d4cce553"]
}

variable "launch_template_instance_types" {
  type        = list(string)
  description = "List of instance types for each launch template"
  default     = ["t3a.medium"]
}


variable "launch_template_instance_keypair" {
  type        = string
  default     = "temp"
  description = "SSH key pair name used for instances in the auto-scaling group"
}

variable "launch_template_instance_name" {
  type        = string
  default     = "Terraform_asg_ec2"
  description = "Name of the EC2 instance created by the auto-scaling group"
}

// security group ids
variable "launch_template_security_groups" {
  type        = list(list(string))
  description = "List of security group IDs for each launch template (nested list)"
  default     = []
}


variable "launch_template_user_data" {
  type        = list(string)
  description = "List of custom user-data scripts for each launch template (optional)"
  default     = []
}


variable "launch_template_iam_instance_profile" {
  type        = list(string)
  description = "List of iam instance profile-role for each launch template (optional)"
  default     = []
}