region       = "ap-southeast-2"
aws_profile  = "agentcis-development"
environment  = "development"
project_name = "Agentcis"
creator      = "subash.chaudhary@globalyhub.com"
vpc-id       = "vpc-088b623dd6702c325" // terraform-manual-vpc
public_subnet_ids = [
  "subnet-0da79630200049eac", // ap-southeast-2a
  "subnet-0d2f982bd7171b329", // ap-southeast-2b
  "subnet-0f7fb9330d181fb68"  // ap-southeast-2c
]
private_subnet_ids = [
  "subnet-0da11260c7546ab19", // ap-southeast-2a
  "subnet-0a501d6e0f51df9c9", // ap-southeast-2b
  "subnet-0c6b80c00b45454f2"  // ap-southeast-2c
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
k8s_worker_ssh_pub_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbL6YAjZw9lJ/GosOIKEQF4lGpZ73DGid593MW2xget kubernetes.agentcis@staging.com"

########### auto-caling ###############
default_worker_instance_size   = "t3.medium"
queue_worker_instance_size     = "m6a.large"
webserver_worker_instance_size = "m6a.large"