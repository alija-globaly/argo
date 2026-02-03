############### tags ###############
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

############### route-53 ###################
variable "domain_name" {
  description = "The ID of the existing VPC where the subnet will be created."
  default     = "terraform-default"
}

variable "vpc-id" {
  description = "The ID of the existing VPC where the subnet will be created."
  default     = "vpc-088b623dd6702c325"
}

########### sub-domain records ############
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

variable "dns_ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 300
}

