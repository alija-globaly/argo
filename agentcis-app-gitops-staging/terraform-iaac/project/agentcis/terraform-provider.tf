terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    encrypt = true
    #dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region                   = var.region
  profile                  = var.aws_profile
  shared_config_files      = [pathexpand("~/.aws/config")]
  shared_credentials_files = [pathexpand("~/.aws/credentials")]
}


################ For static path define ###############
####### both windows and linux #############
# provider "aws" {
#   region  = "ap-southeast-2"
#   #profile = "agentcis-staging" 
#   shared_config_files      = ["/home/ubuntu/.aws/config"]
#   shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
#   shared_config_files      = ["c:/Users/Dell/.aws/conf"]
#   shared_credentials_files = ["c:/Users/Dell/.aws/credentials"]
# }
