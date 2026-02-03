# import {
#   to = aws_vpc.existing_vpc
#   id = "vpc-088b623dd6702c325"
# }

module "main_infrastrcure" {
  source                         = "../../infrastructure/templates-agentcis"
  github_repositories            = var.github_repositories
  vpc-id                         = var.vpc-id
  public_subnet_ids              = var.public_subnet_ids
  private_subnet_ids             = var.private_subnet_ids
  ssh_key_name                   = var.ssh_key_name
  project_name                   = var.project_name
  environment                    = var.environment
  creator                        = var.creator
  primary_admin_ssh_pub_key      = var.primary_admin_ssh_pub_key
  secondary_admin_ssh_pub_key    = var.secondary_admin_ssh_pub_key
  k8s_worker_ssh_pub_key         = var.k8s_worker_ssh_pub_key
  ####### instance size ##################
  k8s_root_master_instance_type = var.k8s_root_master_instance_type
  default_worker_instance_size   = var.default_worker_instance_size
  queue_worker_instance_size     = var.queue_worker_instance_size
  webserver_worker_instance_size = var.webserver_worker_instance_size
  k8s_worker_v_1_32_ami          = var.k8s_worker_v_1_32_ami
  k8s_worker_v_1_35_ami          = var.k8s_worker_v_1_35_ami

  ############ static variables ################
  k8s_master_instance_type      = "m6a.large"
  ubuntu_24_ami                 = "ami-0b8d527345fdace59"
  domain_name                   = "agentcis" // actual domain yesto xa "${var.domain_name}-${var.environment}.internal"
  k8s_pods_destination_cidr     = "10.1.0.0/16"
  root_setup_script_url         = "https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/canonical-k8s-root-node-setup.sh"
  aws_master_setup_script_url   = "https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/k8s-cluster-join-master.sh"
  worker_setup_script_url       = "https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/k8s-cluster-join-worker.sh"

  ############## flags for resources ##################
  oidc_create            = var.oidc_create
  k8s_root_master_server = var.k8s_root_master_server
  k8s_aws_elb_master     = var.k8s_aws_elb_master
  default_auto_scaling   = var.default_auto_scaling
  other_auto_scaling     = var.other_auto_scaling
}