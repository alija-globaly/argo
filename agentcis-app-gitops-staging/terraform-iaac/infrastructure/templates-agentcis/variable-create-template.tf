################### common variable ################
variable "ssh_key_name" {
  description = "SSH key pair name (null disables SSH)"
  type        = string
  default     = null
}

variable "environment" {
  type    = string
  default = "staging"

}

variable "project_name" {
  type        = string
  default     = "terraform-default"
  description = "Tag for project"
}

variable "creator" {
  type        = string
  default     = "subash.chaudhary@globalyhub.com"
  description = "Tag for creator name"
}

variable "root_setup_script_url" {
  type        = string
  default     = "https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/canonical-k8s-root-node-setup.sh"
  description = "URL for the script to setup bashscript"
}

variable "aws_master_setup_script_url" {
  type        = string
  default     = "https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/k8s-cluster-join-master.sh"
  description = "URL for the script to setup bashscript"
}

variable "worker_setup_script_url" {
  type        = string
  default     = "https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/k8s-worker-node-setup.sh"
  description = "URL for the script to setup bashscript"
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



#####################  resource creation variable#####################

##### VPC ############
variable "vpc_name" {
  type        = string
  default     = "terraform-default"
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
    "4240",       #  Cilium health checks
    "5672",       # RabbitMQ / AMQP (application-specific)
    "6400",       # RabbitMQ / AMQP (application-specific)    
    "6443",       # Kubernetes API Server (cluster join + all control)
    "8080",       # temporary testing kubernetes port forwards
    "8472",       # CNI overlay networking (VXLAN – Cilium/Flannel)
    "10250-10259" # kubelet, controller-manager, scheduler ports # Kubelet API + Kube-controller-manager +  Kube-schedule  ## https://kubernetes.io/docs/reference/networking/ports-and-protocols/
  ]
  description = "port of security group will be created"
}

variable "k8s_sg_ingress_cidrs" {
  type = list(string)
  default = [
    "0.0.0.0/0",     # 22 -> SSH – usually restricted later to bastion / admin IPs
    "0.0.0.0/0",     # 80 -> HTTP – public ingress
    "0.0.0.0/0",     # 443 -> HTTPS – public ingress
    "0.0.0.0/0",     # 1025 -> SMTP
    "172.34.0.0/16", # 2379-2380 -> etcd – internal control-plane only
    "172.34.0.0/16", # 4240 -> Cilium health checks
    "172.34.0.0/16", # 5672 -> RabbitMQ – internal services only
    "172.34.0.0/16", # 6400 -> k8s cluster join – internal services only    
    "172.34.0.0/16", # 6443 -> Kubernetes API – nodes / internal access
    "0.0.0.0/0",     # 8080 -> temporary testing kubernetes port forwards
    "172.34.0.0/16", # 8472 -> CNI overlay – node-to-node traffic
    "172.34.0.0/16"  # 10250-10259 -> kubelet / controller / scheduler – internal only
  ]
  description = "cidr of security group will be created"
}

###################### EC2 variable #############
############## instane type
variable "nfs_instance_type" {
  type    = string
  default = "t3.small"
}

variable "k8s_root_master_instance_type" {
  type    = string
  default = "m6a.large"

}

variable "k8s_master_instance_type" {
  type    = string
  default = "t3.medium"

}

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


############ instance AMI
variable "ubuntu_24_ami" {
  type    = string
  default = "ami-0b8d527345fdace59"
}


variable "k8s_worker_v_1_32_ami" {
  type    = string
  default = "ami-081fc13fa16857370"
}

variable "k8s_worker_v_1_35_ami" {
  type    = string
  default = "ami-06e096e94d3ff9b96"
}

########### IAM roles
variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume this role"
  type        = list(string)
  default     = []
}


######## DNS ####################
variable "domain_name" {
  description = "The ID of the existing VPC where the subnet will be created."
  default     = "terraform-default"
}
variable "subdomains" {
  description = "List of subdomain names"
  type        = list(string)
  default     = ["test", "check", "random"]
}

variable "record_types" {
  description = "List of DNS record types (A, CNAME, TXT, MX, etc.)"
  type        = list(string)
  default     = ["A", "A", "A", "CNAME"]
}

# List of record values (IPs for A records, domain names for CNAME, etc.)
variable "record_values" {
  description = "List of record values (IP addresses, CNAME targets, etc.)"
  type        = list(string)
  default     = ["192.168.10.2", "192.168.10.3", "192.168.10.4", "test.myapp-dev.internal"]
}

################### auto scaling variables #####################
variable "asg_instance_types" {
  type        = list(string)
  description = "List of asg server size and types for each ASG"
  default     = []
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

