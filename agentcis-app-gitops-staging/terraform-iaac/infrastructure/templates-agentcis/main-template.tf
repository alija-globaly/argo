########## iam roles ##################
# module "iam_identity_openid_create" {
#   source = "../modules/create-services/aws-permissions/identity-providers"
#     environment      = var.environment
#     creator          = var.creator
#     project_name     = var.project_name     
# }

module "create_github_iam_role" {
  source              = "../modules/create-services/aws-permissions/github-policy-and-roles"
  environment         = var.environment
  creator             = var.creator
  project_name        = var.project_name
  github_repositories = var.github_repositories

}

module "create_k8s_iam_role" {
  source       = "../modules/create-services/aws-permissions/k8s-policy-and-roles"
  project_name = var.project_name
  creator      = var.creator
  environment  = var.environment
}

# module "level_0_user_and_group_create" {
#   source         = "../modules/create-services/aws-permissions/user-and-groups"
#   group_name     = "level-0-${var.group_name}"
#   user_name_list = var.user_name_list
#   project_name   = var.project_name
#   creator        = var.creator
#   environment    = var.environment
# }

# ########### security group for allowing traffic #############
module "create_loadbalancer_sg" {
  source = "../modules/create-services/security-group"
  vpc_id = module.create_vpc.vpc-id
  #sg_name          = var.loadbalancer_sg_name
  sg_name          = "loadbalancer-L7"
  sg_ingress_ports = var.loadbalancer_sg_ingress_ports
  sg_ingress_cidrs = var.loadbalancer_sg_ingress_cidrs
  environment      = var.environment
  creator          = var.creator
  project_name     = var.project_name

}

module "create_k8s_sg" {
  source = "../modules/create-services/security-group"
  vpc_id = module.create_vpc.vpc-id
  #sg_name          = var.k8s_sg_name
  sg_name          = "kubernetes-k8s"
  sg_ingress_ports = var.k8s_sg_ingress_ports
  sg_ingress_cidrs = var.k8s_sg_ingress_cidrs
  vpc_icmp_cidr    = module.create_vpc.vpc_cidr_block
  environment      = var.environment
  creator          = var.creator
  project_name     = var.project_name
}
# # ################# server infrastructure #####################

module "create_ec2_k8s_root_servers" {
  #### syntax condition ? value_if_true : value_if_false
  count = var.k8s_root_master_server ? 1 : 0
  source       = "../modules/create-services/ec2-list"
  ssh_key_name = var.ssh_key_name
  instance_name = [
    "k8s-nfs-storage",
    "k8s-root-master-nginx"
  ]
  #instance_type = ["c6a.large","r6a.large", "m6a.large","t3a.medium"]
  instance_type = [
    var.nfs_instance_type,
    var.k8s_root_master_instance_type
  ]

  ami_id = [
    var.ubuntu_24_ami,
    var.ubuntu_24_ami
  ]

  subnet_id = [
    module.create_subnets.public_subnet_ids[0], // k8s root
    module.create_subnets.public_subnet_ids[0]  // k8s master
  ]
  root_volume_size_gb = [
    30, // k8s root
    30  // k8s master
  ]
  security_group_id = [
    module.create_k8s_sg.core_security_group_id,
    module.create_k8s_sg.core_security_group_id
  ]
  iam_instance_profile = [
    module.create_k8s_iam_role.k8s_aws_load_balancer_controller_instance_profile_name,
    module.create_k8s_iam_role.k8s_aws_load_balancer_controller_instance_profile_name
  ]
  user_data = [
    # First instance: k8s-root-master-nginx (master-root node)
    <<-EOF
      #!/bin/bash
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-file.txt
      echo "## START => ssh keys added by terrafom srcipt" >> /home/ubuntu/.ssh/authorized_keys
      echo "${var.primary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      echo "${var.secondary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      echo "${var.k8s_worker_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      echo "## END => ssh keys added by terrafom srcipt" >> /home/ubuntu/.ssh/authorized_keys
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-complete.txt
    EOF
    ,
    # Second instance: k8s-master-aws-elb (master node)
    <<-EOF
      #!/bin/bash

      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-start.txt
      echo "## START => ssh keys added by terrafom srcipt" >> /home/ubuntu/.ssh/authorized_keys
      echo "${var.primary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      echo "${var.secondary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      echo "${var.k8s_worker_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      echo "## END => ssh keys added by terrafom srcipt" >> /home/ubuntu/.ssh/authorized_keys

      sleep 45

      #systemctl is-system-running --wait
      sudo -u ubuntu bash -c "
        set -e
        curl -fsSL ${var.root_setup_script_url} | tr -d '\r' | bash
      "
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-complete.txt
    EOF
  ]
  project_name = var.project_name
  creator      = var.creator
  environment  = var.environment
}

##################### k8s pod routing ################
# module "k8s_root_master_routing" {
#   source = "../modules/create-services/ec2-k8s-route"

#   instance_id               = module.create_ec2_k8s_root_servers.instance_id["k8s-root-master-nginx"]
#   route_table_id            = module.create_subnets.public_route_table_ids[0]
#   network_interface_id      = module.create_ec2_k8s_root_servers.primary_network_interface_id["k8s-root-master-nginx"]
#   k8s_pods_destination_cidr = var.k8s_pods_destination_cidr
# depends_on = [
#   module.create_ec2_k8s_root_servers
# ]
# }

################ DNS ############
module "create_route_53_dns" {
  source = "../modules/create-services/route-53"
  ###### zone ###########
  domain_name = var.domain_name
  vpc-id      = var.vpc-id
  ####### dns records #######
  subdomains = [
    "nfs",
    "k8s-root-master"
  ]
  record_types = [
    "A",
    "A"
  ]
  record_values = [
    // module.create_ec2_k8s_root_servers.private_ip_address["k8s-nfs-storage"],
    module.create_ec2_k8s_root_servers[0].private_ip_address["k8s-nfs-storage"],
    module.create_ec2_k8s_root_servers[0].private_ip_address["k8s-root-master-nginx"]
     // module.create_ec2_k8s_root_servers.private_ip_address["k8s-root-master-nginx"]
  ]
  environment  = var.environment
  project_name = var.project_name
  creator      = var.creator
  ####### creating only if create_ec2_k8s_root_servers is created
  depends_on = [
    module.create_ec2_k8s_root_servers
  ]

}

# ################ Server scaling ################
module "create_launch_template" {
  source = "../modules/create-services/launch-template"
  launch_template_names = [
    "default-worker",
    "web-server-worker",
    "queue-server-worker"
  ]

  launch_template_ami_ids = [
    var.k8s_worker_v_1_35_ami, # k8s-master AMI
    var.k8s_worker_v_1_35_ami, # k8s-worker AMI
    var.k8s_worker_v_1_35_ami  # bastion AMI
  ]
  launch_template_iam_instance_profile = [
    module.create_k8s_iam_role.k8s_aws_load_balancer_controller_instance_profile_name,
    module.create_k8s_iam_role.k8s_aws_load_balancer_controller_instance_profile_name,
    module.create_k8s_iam_role.k8s_aws_load_balancer_controller_instance_profile_name
  ]
  launch_template_instance_types = [
    "t3.medium", // default
    "t3.medium", // web
    "t3.medium"  // queue
  ]
  launch_template_instance_keypair = var.ssh_key_name
  launch_template_security_groups = [
    [module.create_k8s_sg.core_security_group_id], // default
    [module.create_k8s_sg.core_security_group_id], // web
    [module.create_k8s_sg.core_security_group_id]  // queue
  ]
  ####### user-data ###########
  launch_template_user_data = [
    # First instance: queue-server-worker
    <<-EOF
      #!/bin/bash
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-file.txt
      echo "${var.primary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      sleep 45
      #systemctl is-system-running --wait
      K8S_MASTER_IP=${module.create_ec2_k8s_root_servers[0].private_ip_address["k8s-root-master-nginx"]}
      sudo -u ubuntu bash -c "
        set -e
        curl -fsSL ${var.worker_setup_script_url} | tr -d '\r' | \
          bash -s -- --worker default-server-worker
      "
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-complete.txt
    EOF
    ,
    # Second instance: web-server-worker (master node)
    <<-EOF
      #!/bin/bash
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-file.txt
      echo "${var.primary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      sleep 45
      sudo -u ubuntu bash -c "
        curl -fsSL ${var.worker_setup_script_url} | tr -d '\r' | \
          bash -s -- --worker web-server-worker
      "
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-complete.txt
    EOF
    ,
    # Second instance: default-server-worker (master node)
    <<-EOF
      #!/bin/bash
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-file.txt
      echo "${var.primary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
      sleep 45
      sudo -u ubuntu bash -c "
        set -e
        curl -fsSL ${var.worker_setup_script_url} | tr -d '\r' | \
          bash -s -- --worker queue-server-worker
      "
      touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-complete.txt
    EOF    
  ]
  ########## Tags ###########
  environment  = var.environment
  project_name = var.project_name
  creator      = var.creator
}


# ################################### Phase-3 setup : case and environemnt specific ###################

# ################## worker setup ##################

module "create_ec2_k8s_elb_master" {
  ##### syntax condition ? value_if_true : value_if_false
  count = var.k8s_aws_elb_master ? 1 : 0

  source       = "../modules/create-services/ec2-list"
  ssh_key_name = var.ssh_key_name
  instance_name = [
    "k8s-master-aws-elb"
  ]
  #instance_type = ["c6a.large","r6a.large", "m6a.large","t3a.medium"]
  instance_type = [
    var.k8s_master_instance_type
  ]

  ami_id = [
    var.k8s_worker_v_1_35_ami
  ]

  subnet_id = [
    module.create_subnets.public_subnet_ids[0], // k8s root
  ]
  root_volume_size_gb = [
    30, // k8s root
  ]
  security_group_id = [
    module.create_k8s_sg.core_security_group_id
  ]
  iam_instance_profile = [
    module.create_k8s_iam_role.k8s_aws_load_balancer_controller_instance_profile_name
  ]
  user_data = [
    # First instance: k8s-root-master-nginx (master-root node)
    <<-EOF
    #!/bin/bash

    touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-start.txt
    echo "## START => ssh keys added by terrafom srcipt" >> /home/ubuntu/.ssh/authorized_keys
    echo "${var.primary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
    echo "${var.secondary_admin_ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
    echo "## END => ssh keys added by terrafom srcipt" >> /home/ubuntu/.ssh/authorized_keys

    sleep 45
    sudo -u ubuntu bash -c "
      curl -fsSL ${var.aws_master_setup_script_url} | tr -d '\r' | \
        bash -s -- --master k8s-root-master.${var.domain_name}-${var.environment}.internal
    "
    touch /home/ubuntu/k8s-root-master.${var.domain_name}-${var.environment}.internal-complete.txt
    EOF
  ]
  project_name = var.project_name
  creator      = var.creator
  environment  = var.environment
  ###### creating only after create_ec2_k8s_root_servers is executed
  depends_on = [
    module.create_ec2_k8s_root_servers
  ]
}

# # ####################################################
# # ############## auto-scaling-groups ################
# # ###################################################

# # ################# for Non-Production #############
module "create_k8s_autoscaling_group_default" {
  ###########  development, staigng and other (not matching production) ###################
  ##### syntax condition ? value_if_true : value_if_false
  count  = var.default_auto_scaling ? 1 : 0
  source = "../modules/create-services/auto-scaling-group"
  #asg_name                       = var.launch_template_instance_name
  asg_names = ["default-worker"]
  asg_ec2_min_capacities = [
    "1" // default-server
  ]
  asg_ec2_max_capacities = [
    "2" // default-server
  ]
  asg_ec2_desired_capacities = [
    "1" // default-server
  ]
  subnet_ids_list = [
    [module.create_subnets.public_subnet_ids[0], module.create_subnets.public_subnet_ids[1]] # web-server subnets (wrapped in [])
  ]
  launch_template_ids = [
    // "lt-0995ae00ace1ccd6c"
    module.create_launch_template.launch_template_ids["default-worker"] // default-server
  ]
  launch_template_versions = [
    module.create_launch_template.launch_template_default_versions["default-worker"] // default-server
  ]
  asg_instance_types = [var.default_worker_instance_size]
  environment        = var.environment
  project_name       = var.project_name
  creator            = var.creator
}

# ############### production #########################
module "create_k8s_autoscaling_group_prod" {
  ########### only creating for production ###################
  ##### syntax condition ? value_if_true : value_if_false
  #count  = var.environment == "production" ? 1 : 0
  count = var.other_auto_scaling ? 1 : 0

  source = "../modules/create-services/auto-scaling-group"
  #asg_name                       = var.launch_template_instance_name
  asg_names = ["web-server-worker", "web-server"]
  asg_ec2_min_capacities = [
    "1", // queue-server
    "1"  // webserver
  ]
  asg_ec2_max_capacities = [
    "1", // queue-server
    "2"  // webserver
  ]
  asg_ec2_desired_capacities = [
    "1", // queue-server
    "1"  // webserver
  ]
  subnet_ids_list = [
    [module.create_subnets.public_subnet_ids[0], module.create_subnets.public_subnet_ids[1]], # queue-server 
    [module.create_subnets.public_subnet_ids[0], module.create_subnets.public_subnet_ids[1]]  # web-server subnets
  ]
  launch_template_ids = [
    module.create_launch_template.launch_template_ids["web-server-worker"],  // queue-server
    module.create_launch_template.launch_template_ids["queue-server-worker"] // webserver
  ]
  launch_template_versions = [
    module.create_launch_template.launch_template_default_versions["web-server-worker"],  // queue-server
    module.create_launch_template.launch_template_default_versions["queue-server-worker"] // webserver
  ]
  asg_instance_types = [
    var.webserver_worker_instance_size,
    var.queue_worker_instance_size
  ]
  environment  = var.environment
  project_name = var.project_name
  creator      = var.creator
}