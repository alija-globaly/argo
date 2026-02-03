################# common variable and tags ############
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

########## single value vairable #############

variable "asg_default_cooldown" {
  type        = string
  default     = "300"
  description = "default cool-down"
}

variable "asg_heathcheck_type" {
  type    = string
  default = "EC2"

}

############## array vairable ###############
variable "asg_names" {
  type        = list(string)
  description = "List of ASG names"
  default     = ["terraform-default"]
}

variable "asg_ec2_desired_capacities" {
  type        = list(number)
  description = "List of desired capacities for each ASG"
  default     = ["1"]
}

variable "asg_ec2_min_capacities" {
  type        = list(number)
  description = "List of minimum capacities for each ASG"
  default     = ["1"]
}

variable "asg_ec2_max_capacities" {
  type        = list(number)
  description = "List of maximum capacities for each ASG"
  default     = ["2"]
}

############## blank variables ###################

variable "subnet_ids_list" {
  type        = list(list(string))
  description = "List of subnet IDs for each ASG (nested list)"
  default     = []
}

variable "target_group_arns_list" {
  type        = list(list(string))
  description = "List of target group ARNs for each ASG (nested list, optional)"
  default     = []
}


variable "launch_template_ids" {
  type        = list(string)
  description = "List of launch template IDs for each ASG"
  default     = []
}

variable "launch_template_versions" {
  type        = list(string)
  description = "List of launch template versions for each ASG"
  default     = []
}



variable "asg_instance_types" {
  type        = list(string)
  description = "List of asg server size and types for each ASG"
  default     = []
}