region       = "ap-southeast-2"
aws_profile  = "agentcis-production"
environment  = "production"
project_name = "Agentcis"
creator      = "subash.chaudhary@globalyhub.com"
vpc-id       = "vpc-09e4156d" //IntroCept-vpc
public_subnet_ids = [
  "subnet-6e4bee18", // ap-southeast-2a
  "subnet-521ba736", // ap-southeast-2b
  "subnet-4ea67117"  // ap-southeast-2c
]
private_subnet_ids = [
  "subnet-0dd3185fa0bfec43e", // ap-southeast-2a 
  "subnet-0cb21e85746264a99", // ap-southeast-2b
  "subnet-0a7cfa1d985978931"  // ap-southeast-2c
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
ssh_key_name              = "agentcis-v3-checkin"
primary_admin_ssh_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCui/GZdXROyaoPCKf2DT6mWwvv6KEtl9K3k9FmmXmxjOV4hyVLG7tfoG0vvz9eyng5+emGTiZ3FCZS8MXx2S64BCAqVBGEdqNvwq4/RMeGq8+4WiEUEPrVpW52vTr3acKNuTw0hL+eYPM1vK/OmNXuqsbtZPkoPmuodkRhYFsUZlPl6dZM4QvpV0Vwv4OrdHddsG/u0HaVEZr+p6AeGrZ2mPlPUQv2Sxd1RdKAfAV4X8J2uVKp/5Lv94bATlqsc9l8J5U9ig/5Jnr2noMv5KoI5pE57Gpq/A35CscAdassuWrjGXsHBARbGomNKxxwdR9KvTJBnr39SRbjB/a/xnfR DELL@DESKTOP-N70J5HB"
########### production ko deployer ko key #################
secondary_admin_ssh_pub_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6yn+On2u1q94iCcKFPoRj3j7LSf0/BWCcyv17sDHHd subash.chaudhary.agentcis@globalyhub.com"

########### auto-caling ###############
default_worker_instance_size   = "m6a.large"
queue_worker_instance_size     = "m6a.large"
webserver_worker_instance_size = "m6a.large"
############ flags ###########
k8s_aws_elb_master     = true
k8s_root_master_server = true
default_auto_scaling   = true
oidc_create            = false
other_auto_scaling     = true
