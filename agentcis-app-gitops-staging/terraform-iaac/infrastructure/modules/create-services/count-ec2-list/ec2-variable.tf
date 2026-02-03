############ imported vairable ##########
# variable "vpc_id" {
#   type        = string
#   description = "VPC ID used to create subnet"
# }
############ common vairable ##############
variable "ssh_key_name" {
  description = "SSH key pair name (null disables SSH)"
  type        = string
  default     = null
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

###############  EC2 Variable ##################

variable "instance_name" {
  description = "Type of EC2 instance"
  type        = list(string)
  default     = ["devops-test-ec2"]
}

variable "ami_id" {
  type        = list(string)
  default     = ["ami-060e277c0d4cce553"]
  description = "Amazon Machine Image (AMI) ID for the instance. Default Ubuntu Server 24.04 LTS (HVM) image"
}

variable "subnet_id" {
  type        = list(string)
  default     = []
  description = "Subnet ID where the EC2 instance will be deployed"
}

variable "security_group_id" {
  type        = list(string)
  default     = []
  description = "Security group ID(s) assigned to the EC2 instance"
}

variable "instance_type" {
  type        = list(string)
  default     = ["t2.micro"]
  description = "type of EC2 instance in terms of CPU capacity"
}

variable "root_volume_size_gb" {
  type        = list(string)
  default     = ["60"]
  description = "Size of the root volume attached to the EC2 instance"
}

variable "iam_instance_profile" {
  description = "instance profile"
  type        = list(string)
  default     = ["subash-test-ec2-iam-irsa"]
}

variable "user_data" {
  description = "User data scripts for each EC2 instance"
  type        = list(string)
  default     = []
}