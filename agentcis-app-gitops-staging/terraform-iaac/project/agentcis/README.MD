### dev

```bash
terraform init -backend-config=environment/development/backend.hcl
terraform plan  -var-file="environment/development/terraform.tfvars"
terraform apply -var-file="environment/development/terraform.tfvars" -auto-approve
terraform destroy -var-file="environment/development/terraform.tfvars" -auto-approve
```

### staging
```bash
terraform init
terraform init -backend-config=environment/staging/backend.hcl
terraform init -backend-config=backend-staging.hcl -migrate-state

terraform plan  -var-file="environment/staging/terraform.tfvars"
terraform apply -var-file="environment/staging/terraform.tfvars" -auto-approve
terraform destroy -var-file="environment/staging/terraform.tfvars" -auto-approve
```

### production

```bash
terraform init
terraform plan  -var-file="terraform-production.tfvars" -auto-approve
terraform apply -var-file="terraform-production.tfvars"
terraform destroy -var-file="terraform-production.tfvars"
```

### using Make

```bash
make init

make plan-staging
make apply-staging
make destroy-staging

make plan-production
make apply-production
make destroy-production
```

```
terraform state rm 'module.main_infrastrcure.module.create_ec2_k8s_root_servers.aws_instance.ec2_instance["k8s-root-master-nginx"]'
terraform destroy -target='module.main_infrastrcure.module.create_ec2_k8s_root_servers.aws_instance.ec2_instance["k8s-root-master-nginx"]' -var-file="environment/staging/terraform.tfvars"
```

# Make a node a voter (can become leader)
sudo k8s set-node-role 172.34.11.252 voter

# Make a node a spare (cannot become leader)
sudo k8s set-node-role 172.34.15.242 spare