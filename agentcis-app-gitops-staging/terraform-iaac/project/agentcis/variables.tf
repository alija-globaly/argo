###########  provider ###########
variable "aws_profile" {
  type        = string
  description = "AWS CLI profile to use for this environment"
}


variable "region" {
  type        = string
  description = "region use for this environment"
}
############### Tag #############
variable "environment" {
  type        = string
  description = "Deployment environment (staging, production, etc)"
}

variable "project_name" {
  type        = string
  description = "Project tag name"
}

variable "creator" {
  type        = string
  description = "Resource creator / owner"
}

variable "k8s_worker_v_1_35_ami" {
  type    = string
  default = "ami-06e096e94d3ff9b96"
}

variable "k8s_worker_v_1_32_ami" {
  type    = string
  default = "ami-081fc13fa16857370"
}


variable "primary_admin_ssh_pub_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCui/GZdXROyaoPCKf2DT6mWwvv6KEtl9K3k9FmmXmxjOV4hyVLG7tfoG0vvz9eyng5+emGTiZ3FCZS8MXx2S64BCAqVBGEdqNvwq4/RMeGq8+4WiEUEPrVpW52vTr3acKNuTw0hL+eYPM1vK/OmNXuqsbtZPkoPmuodkRhYFsUZlPl6dZM4QvpV0Vwv4OrdHddsG/u0HaVEZr+p6AeGrZ2mPlPUQv2Sxd1RdKAfAV4X8J2uVKp/5Lv94bATlqsc9l8J5U9ig/5Jnr2noMv5KoI5pE57Gpq/A35CscAdassuWrjGXsHBARbGomNKxxwdR9KvTJBnr39SRbjB/a/xnfR DELL@DESKTOP-N70J5HB"
  description = "ssh public key for admin"
}

variable "secondary_admin_ssh_pub_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCui/GZdXROyaoPCKf2DT6mWwvv6KEtl9K3k9FmmXmxjOV4hyVLG7tfoG0vvz9eyng5+emGTiZ3FCZS8MXx2S64BCAqVBGEdqNvwq4/RMeGq8+4WiEUEPrVpW52vTr3acKNuTw0hL+eYPM1vK/OmNXuqsbtZPkoPmuodkRhYFsUZlPl6dZM4QvpV0Vwv4OrdHddsG/u0HaVEZr+p6AeGrZ2mPlPUQv2Sxd1RdKAfAV4X8J2uVKp/5Lv94bATlqsc9l8J5U9ig/5Jnr2noMv5KoI5pE57Gpq/A35CscAdassuWrjGXsHBARbGomNKxxwdR9KvTJBnr39SRbjB/a/xnfR DELL@DESKTOP-N70J5HB"
  description = "ssh public key for admin"
}

variable "k8s_worker_ssh_pub_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbL6YAjZw9lJ/GosOIKEQF4lGpZ73DGid593MW2xget kubernetes.agentcis@staging.com"
  description = "ssh public key for admin"
}


####### AWS resources ####################
variable "vpc-id" {
  type        = string
  description = "VPC-ID for aws resources"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "ssh_key_name" {
  description = "SSH key pair name (null disables SSH)"
  type        = string
  default     = null
}

########### Github Repositories ###########
variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume this role"
  type        = list(string)
  default = [
    "GlobalyHub/agentcis-app",
    "GlobalyHub/agentcis-agent-portal" // jamma 2 wota repo lai by default haleko xu 
    # "GlobalyHub/agentcis-v2",
    # "GlobalyHub/agentcis-website",
    # "GlobalyHub/agentcis-super-admin",
    # "GlobalyHub/agentcis-new-landing-page",
    # "GlobalyHub/agentcis-app-gitops"
  ]
}


########## dns ###############
variable "domain_name" {
  description = "The ID of the existing VPC where the subnet will be created."
  default     = "terraform-default"
}


########### auto-scaling #############
variable "default_worker_instance_size" {
  type    = string
  default = "t3.medium"
}

variable "queue_worker_instance_size" {
  type    = string
  default = "t3.medium"
}

variable "webserver_worker_instance_size" {
  type    = string
  default = "t3.medium"
}

################ Flags variable #############
variable "oidc_create" {
  description = "Enable Auto Scaling Group creation"
  type        = bool
  default     = false
}

variable "k8s_root_master_server" {
  description = "Enable Auto Scaling Group creation"
  type        = bool
  default     = false
}

variable "k8s_aws_elb_master" {
  description = "Enable Auto Scaling Group creation"
  type        = bool
  default     = false
}


variable "default_auto_scaling" {
  description = "Enable Auto Scaling Group creation"
  type        = bool
  default     = false
}

variable "other_auto_scaling" {
  description = "Enable Auto Scaling Group creation"
  type        = bool
  default     = false
}

variable "k8s_root_master_instance_type" {
  type    = string
  default = "m6a.large"

}

