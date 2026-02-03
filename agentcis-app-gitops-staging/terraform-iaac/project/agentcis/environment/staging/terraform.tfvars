region       = "ap-southeast-2"
aws_profile  = "agentcis-staging"
environment  = "staging"
project_name = "Agentcis"
creator      = "subash.chaudhary@globalyhub.com"
vpc-id       = "vpc-26227943" //IntroCept-vpc
public_subnet_ids = [
  "subnet-18a6b77d", // ap-southeast-2a
  "subnet-91300ce6", // ap-southeast-2b
  "subnet-f1545db7"  // ap-southeast-2c
]
private_subnet_ids = [
  "subnet-044c3913a4297b34e", //ap-southeast-2a
  "subnet-0d6d5de3d4941f959", //ap-southeast-2b
  "subnet-03098f51461700f55"  // ap-southeast-2c
]
github_repositories = [
  "GlobalyHub/agentcis-app",
  "GlobalyHub/agentcis-agent-portal",
  "GlobalyHub/agentcis-v2",
  "GlobalyHub/agentcis-website",
  "GlobalyHub/agentcis-super-admin",
  "GlobalyHub/agentcis-new-landing-page",
  "GlobalyHub/agentcis-app-gitops"
]
ssh_key_name                = "agentcis-v3-stagging"
primary_admin_ssh_pub_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCui/GZdXROyaoPCKf2DT6mWwvv6KEtl9K3k9FmmXmxjOV4hyVLG7tfoG0vvz9eyng5+emGTiZ3FCZS8MXx2S64BCAqVBGEdqNvwq4/RMeGq8+4WiEUEPrVpW52vTr3acKNuTw0hL+eYPM1vK/OmNXuqsbtZPkoPmuodkRhYFsUZlPl6dZM4QvpV0Vwv4OrdHddsG/u0HaVEZr+p6AeGrZ2mPlPUQv2Sxd1RdKAfAV4X8J2uVKp/5Lv94bATlqsc9l8J5U9ig/5Jnr2noMv5KoI5pE57Gpq/A35CscAdassuWrjGXsHBARbGomNKxxwdR9KvTJBnr39SRbjB/a/xnfR DELL@DESKTOP-N70J5HB"
secondary_admin_ssh_pub_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnMmoPb2f1SlwSNKBOpV6Tj6x/O4X6JbbNON+38fuir alija@lenovo"
######## v 1.32 key
# k8s_worker_ssh_pub_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbL6YAjZw9lJ/GosOIKEQF4lGpZ73DGid593MW2xget kubernetes.agentcis@staging.com"

##### v 1.35 key
k8s_worker_ssh_pub_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFc8dnHXvjz7ws4IDsYJiX4O+LEdl/xHefT78/h2Nb+q kubernetes.agentcis@staging.com"

########### AMI #####################
k8s_worker_v_1_35_ami = "ami-06e096e94d3ff9b96"
k8s_worker_v_1_32_ami = "ami-081fc13fa16857370"

########### auto-caling ###############
k8s_root_master_instance_type = "m6a.large"
default_worker_instance_size   = "t3.medium"
queue_worker_instance_size     = "m6a.large"
webserver_worker_instance_size = "m6a.large"

################ flags #######################
oidc_create            = false
k8s_root_master_server = true
k8s_aws_elb_master     = true
default_auto_scaling   = false
other_auto_scaling     = false
