################### common variable ################
variable "environment" {
  type    = string
  default = "staging"

}

variable "project_name" {
  type        = string
  default     = "devops-terraform"
  description = "Tag for project"
}

#####################  resource creation variable#####################

##### VPC ############
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

####### subnet #########
variable "subnet_availability_zones" {
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  description = "List of availability zones"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["172.17.10.0/24", "172.17.20.0/24", "172.17.30.0/24"]
  description = "List of CIDR blocks for public subnets"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["172.17.1.0/24", "172.17.2.0/24", "172.17.3.0/24"]
  description = "List of CIDR blocks for private subnets"
}

############## security group ################
######### alb #################
variable "loadbalancer_sg_name" {
  type    = string
  default = "terraform-web-default-sg"

}

variable "loadbalancer_sg_ingress_ports" {
  type        = list(string)
  default     = ["80", "443"]
  description = "port of security group will be created"
}

variable "loadbalancer_sg_ingress_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0", "0.0.0.0/0"]
  description = "cidr of security group will be created"
}

########## kubernetes #############
variable "k8s_sg_name" {
  type    = string
  default = "terraform-web-default-sg"

}

variable "k8s_sg_ingress_ports" {
  type = list(string)
  default = [
    "22",         # SSH access to nodes (admin / automation)
    "80",         # HTTP (ingress controllers, optional)
    "443",        # HTTPS (ingress controllers, TLS services)
    "1025",       # SMTP
    "2379-2380",  # etcd client + peer ports (control-plane only)
    "5672",       # RabbitMQ / AMQP (application-specific)
    "6443",       # Kubernetes API Server (cluster join + all control)
    "8472",       # CNI overlay networking (VXLAN – Cilium/Flannel)
    "10250-10259" # kubelet, controller-manager, scheduler ports
  ]
  description = "port of security group will be created"
}

variable "k8s_sg_ingress_cidrs" {
  type = list(string)
  default = [
    "0.0.0.0/0",     # SSH – usually restricted later to bastion / admin IPs
    "0.0.0.0/0",     # HTTP – public ingress
    "0.0.0.0/0",     # HTTPS – public ingress
    "0.0.0.0/0",     # SMTP
    "172.17.0.0/16", # etcd – internal control-plane only
    "172.17.0.0/16", # RabbitMQ – internal services only
    "172.17.0.0/16", # Kubernetes API – nodes / internal access
    "172.17.0.0/16", # CNI overlay – node-to-node traffic
    "172.17.0.0/16"  # kubelet / controller / scheduler – internal only
  ]
  description = "cidr of security group will be created"
}

###################### EC2 variable #############
############## instane type
variable "nfs_instance_type" {
  type    = string
  default = "t3.small"
}

variable "k8s_master_instance_type" {
  type    = string
  default = "m6a.large"

}

############ instance AMI
variable "nfs_latest_ami" {
  type    = string
  default = "ami-0b8d527345fdace59"
}

variable "k8s_master_latest_ami" {
  type    = string
  default = "ami-0b8d527345fdace59"
}
