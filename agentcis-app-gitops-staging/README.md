# Ansible Presetup

This repository contains Ansible playbooks for preparing infrastructure prerequisites before deploying ArgoCD applications. It automates installation of required tools on a bastion host and deploys ArgoCD into your Kubernetes cluster. All operations are executed through an Ansible environment running inside Docker for consistency and isolation.

---

## Table of Contents

- [Ansible Presetup](#ansible-presetup)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Directory Structure](#directory-structure)
- [Phase 1 : Repository Initialization](#phase-1--repository-initialization)
    - [Running Initialization](#running-initialization)
    - [Script Responsibilities](#script-responsibilities)
- [Phase 2: Bastion Setup using Ansible](#phase-2-bastion-setup-using-ansible)
  - [Inventory Configuration](#inventory-configuration)
  - [Variables](#variables)
  - [SSH Key Configuration](#ssh-key-configuration)
  - [Running Bastion Setup](#running-bastion-setup)
- [Phase 3: ArgoCD Bootstrapping](#phase-3-argocd-bootstrapping)
  - [ArgoCD Access \& Login](#argocd-access--login)
    - [Emergency ArgoCD Login (Retrieve Initial Admin Password)](#emergency-argocd-login-retrieve-initial-admin-password)
  - [Repository Configuration](#repository-configuration)
  - [Application Initialization](#application-initialization)
  - [Final Access](#final-access)
- [Additional Resources](#additional-resources)
- [URLs](#urls)
    - [optional but torubleshooting](#optional-but-torubleshooting)
    - [AWS ELB](#aws-elb)
    - [add this label addition on worker](#add-this-label-addition-on-worker)

---

## Overview

The presetup workflow automates:

1. **Connection Testing** — Ensures SSH reachability of the bastion host.
2. **Bastion Setup** — Installs and configures:

   * `kubectl`
   * `helm`
   * `awscli`
   * Bash completion for Kubernetes tools
3. **ArgoCD Deployment** — Retrieves ArgoCD manifests and deploys them into your Kubernetes cluster.

---

## Prerequisites

You should have:

* Docker and Docker Compose
* SSH access to the bastion host
* SSH private key
* Kubernetes cluster reachable from the bastion host
* Network connectivity between your machine and the bastion
* `kubectl` configuration on the bastion (installed automatically if missing)

---

## Directory Structure

```
ansble-presetup/
├── .ssh-keys/                    # SSH keys directory (gitignored)
│   ├── id_rsa                   # Private SSH key (you need to add this)
│   └── id_rsa.pub               # Public SSH key (optional)
├── .gitignore                   # Git ignore rules for SSH keys
├── ansible.cfg                  # Ansible configuration file
├── docker-compose.yml           # Docker Compose configuration
├── inventories/                 # Ansible inventory files
│   └── hosts                   # Target hosts configuration
├── main.yml                     # Main Ansible playbook
├── Makefile                     # Helper commands for testing
├── manifest/                    # Kubernetes manifests
│   └── argocd-ingress.yml      # ArgoCD ingress configuration
├── tasks/                       # Ansible task files
│   ├── 0-connection-test.yml   # Connection verification task
│   ├── 1.1-bastian-setup.yml   # Bastion host setup tasks
│   └── 1.2-argocd-setup.yml    # ArgoCD deployment tasks
├── variables/                   # Variable files
│   ├── argocd-variable.yml     # ArgoCD-specific variables
│   └── color-code.yml          # Color codes for output
└── README.md                    # This file
```

---

# Phase 1 : Repository Initialization

Before running Ansible, update values in `templates.sed`.
These values are applied to all YAML/YML resources via `init-gitop-repo.sh`.

### Running Initialization

```bash
chmod +x ./init-gitop-repo.sh

# Default branch (staging-gitops-template)
./init-gitop-repo.sh

# Custom branch
./init-gitop-repo.sh --branch staging
./init-gitop-repo.sh --branch <branch-name>

# Help
./init-gitop-repo.sh --help
```

### Script Responsibilities

1. Applies `templates.sed` substitutions to all YAML/YML files
2. Creates or switches the Git branch
3. Stages all modified files
4. Commits with message *"Initializing gitops"*
5. Pushes the branch to the remote repository

---

# Phase 2: Bastion Setup using Ansible

## Inventory Configuration

`inventories/hosts`:

```ini
[bastian_ubuntu]
52.36.57.52 ansible_user=ubuntu
```

---

## Variables

`variables/argocd-variable.yml`:

```yaml
argocd_manifest_dir: /home/ubuntu/argocd-manifests
argocd_manifest_url: https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## SSH Key Configuration

```bash
cd ansble-presetup
mkdir -p .ssh-keys

cp ~/.ssh/id_rsa .ssh-keys/id_rsa
chmod 600 .ssh-keys/id_rsa

# listing files
ls -al .ssh-keys
tree -L 1 .ssh-keys 

#Expected outcome:
.ssh-keys/
├── id_rsa
├── id_rsa.pub
├── id_ed25519
└── id_ed25519.pub
```

---

## Running Bastion Setup

```bash
docker-compose pull
sudo apt install make

#Connectivity Test
make ping-host
docker compose run --rm ansible sh -c "ANSIBLE_STDOUT_CALLBACK=default ansible all -m ping"

#### Setup Execution
make setup-bastian
docker compose run --rm ansible sh -c "ansible-playbook main.yml"

# To run Verbose Modes
docker-compose run --rm ansible ansible-playbook main.yml -v   # level -1
docker-compose run --rm ansible ansible-playbook main.yml -vv # level -3 verbose
docker-compose run --rm ansible ansible-playbook main.yml -vvv # level-3 verbose
```

---

# Phase 3: ArgoCD Bootstrapping


## ArgoCD Access & Login

### Emergency ArgoCD Login (Retrieve Initial Admin Password)

```bash
# Local Access Without Ingress
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:80

# find argocd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Then open:

```
https://<bastion-ip>:8080
```

Default username: **admin**

Update the security group to allow inbound traffic on **8080**.

---

## Repository Configuration

Take sample of `repo-connect-reference/repo-connect.yml`, update user/secret/repo, then apply:

```bash
kubectl apply -f repo-connect.yml
```

---

## Application Initialization

Copy `pre-initialize.yml` and `root-app.yml` to bastian from the branch initialized in Phase-1:

```bash
kubectl apply -f pre-initialize.yml
kubectl apply -f root-app.yml
```

---

## Final Access

Now login to ArgoCD using the **ELB CNAME**.

---

# Additional Resources

---

# URLs

**Documentation URLs**

* [https://docs.ansible.com/](https://docs.ansible.com/)
* [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* [https://argo-cd.readthedocs.io/](https://argo-cd.readthedocs.io/)
* [https://kubernetes.io/docs/](https://kubernetes.io/docs/)

**ArgoCD Manifest URL**

* [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)





```
Troubleshooting command
# Delete the mutating webhook that's blocking Service creation
kubectl delete mutatingwebhookconfiguration aws-load-balancer-webhook

# Also delete validating webhook if it exists
kubectl delete validatingwebhookconfiguration aws-load-balancer-webhook

 sudo k8s get load-balancer
 sudo k8s set load-balancer.cidrs="172.17.20.100-172.17.20.150"
 kubectl get ipaddresspool -n metallb-system
 kubectl get l2advertisement -n metallb-system


export GIT_REPO=https://github.com/owner/installation-repo
export GIT_TOKEN=xxx

argocd-autopilot repo bootstrap --recover --app "${GIT_REPO}.git/bootstrap/argo-cd"

```

url https://argocd-autopilot.readthedocs.io/en/stable/Recovery/ 

sudo dpkg --configure -a

#iam roles binding to ec2
```
aws iam list-instance-profiles-for-role --role-name
aws iam list-instance-profiles-for-role --role-name subash-eks-ec2-irsa-sample
aws iam create-instance-profile   --instance-profile-name subash-eks-ec2-irsa-sample
aws iam list-instance-profiles-for-role --role-name subash-eks-ec2-irsa-sample
aws iam add-role-to-instance-profile   --instance-profile-name subash-eks-ec2-irsa-sample   --role-name subash-eks-ec2-irsa-sample
aws iam list-instance-profiles-for-role --role-name subash-eks-ec2-irsa-sample
```
kubelet config generation
```
sudo mkdir -p /etc/kubernetes/credential-provider
sudo tee /etc/kubernetes/credential-provider/config.yaml <<EOF
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
  - name: ecr-credential-provider
    matchImages:
      - "*.dkr.ecr.*.amazonaws.com"
      - "*.dkr.ecr.*.amazonaws.com.cn"
      - "*.dkr.ecr-fips.*.amazonaws.com"
    defaultCacheDuration: "12h"
    apiVersion: credentialprovider.kubelet.k8s.io/v1
    args:
      - get-credentials
EOF

```

or yaml file

```yml
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
  - name: ecr-credential-provider
    matchImages:
      - "*.dkr.ecr.*.amazonaws.com"
      - "*.dkr.ecr.*.amazonaws.com.cn"
      - "*.dkr.ecr-fips.*.amazonaws.com"
    defaultCacheDuration: "12h"
    apiVersion: credentialprovider.kubelet.k8s.io/v1
    args:
      - get-credentials
```

```

 wget https://github.com/dntosas/ecr-credential-provider/releases/download/v1.2.0/ecr-credential-provider-linux-amd64
 chmod +x ecr-credential-provider-linux-amd64
 sudo mkdir ecr-credential-provider-linux-amd64
 sudo mv ecr-credential-provider-linux-amd64 /usr/local/bin/credential-providers/ecr-credential-provider


 sudo nano /var/snap/k8s/common/args/kubelet
Add these two lines to the kubelet arguments:

--image-credential-provider-config=/etc/kubernetes/credential-provider/config.yaml
--image-credential-provider-bin-dir=/usr/local/bin/credential-providers
```


some troubleshooting commands
```bash
# Check if kubelet is running
sudo snap services k8s
# Check kubelet logs
sudo snap logs k8s.kubelet -n 100
# If kubelet is not running, restart it
sudo snap restart k8s.kubelet
# Or restart all k8s services
sudo snap restart k8s
```


```bash
sudo k8s get-join-token worker --worker

sudo k8s join-cluster <join-token>
sudo k8s get-join-token <node-name> --worker
```

```bash
sudo k8s remove-node worker
sudo k8s remove-node control-plane
sudo k8s remove-node ip-172-34-30-103

```


```bash
#multi-pass
multipass delete control-plane
multipass delete worker
multipass purge
```


```bash
sudo k8s reset
sudo k8s bootstrap

```

### optional but torubleshooting

```bash
kubectl drain ip-172-34-30-103 \
  --ignore-daemonsets \
  --delete-emptydir-data

snap list k8s
sudo journalctl -u snap.k8s.* -f
TOKEN='eyJ0b2tlbiI6IiIsInNlY3JldCI6Indvcmtlcjo6MzFiYjBlM2UyMGVlMDMxNjE5MTQ5YjljM2I0YjBhZmMxM2I0NWQxMSIsImpvaW5fYWRkcmVzc2VzIjpbIjE3Mi4zNC4yOC4yMDg6NjQwMCJdLCJmaW5nZXJwcmludCI6IjIzYWI0ZjNlZjExZTM4MDU3YzllYzRmYmIxOTg5NTQwYWEwMmNmMjJiNDgyM2QzMTk2NGU0MjlhNTQ0MzBjNTYiLCJfIjoibSEhIn0'
echo $TOKEN | base64 --decode | jq

TOKEN=$(ssh ubuntu@172.34.28.208 "sudo k8s get-join-token --worker")

curl -L --progress-bar https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/scripts/k8s-worker-node-setup.sh | bash -s -- --worker queue-server-worker

```


### AWS ELB

```
helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller -f values.yml
kubectl describe ingress  -n demo new-subash-ingress
kubectl scale deployment aws-load-balancer-controller -n kube-system --replicas=1
```
```bash
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/info
```
```bash

kubectl edit deployment aws-load-balancer-controller -n kube-system
```

```yml
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: aws-load-balancer-controller
        app.kubernetes.io/name: aws-load-balancer-controller


    spec:
      hostNetwork: true            # << Add this line
      serviceAccount: aws-load-balancer-controller
      serviceAccountName: aws-load-balancer-controller     ## added 
      containers:
        - name: aws-load-balancer-controller
          image: amazon/aws-alb-ingress-controller:v2.17.0
          args:
            - --cluster-name=k8s-test-cluster
            - --aws-region=ap-southeast-2
            - --ingress-class=alb

```
```bash
kubectl scale deployment aws-load-balancer-controller -n kube-system --replicas=1
```

```bash
# create token for master
sudo k8s get-join-token subash-elb-172-34-22-136

##############
# use sudo k8s to run command without expoting kubectl commnd
sudo k8s kubectl get pods -A
sudo k8s kubectl get nodes
#############
kubectl label node subash-elb-172-34-22-136 role=subash-elb
kubectl get node subash-elb-172-34-22-136 --show-labels

```
```bash
# adding network route for internal hosts
sudo apt install amazon-ec2-utils
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
echo $INSTANCE_ID
aws ec2 modify-instance-attribute   --instance-id $INSTANCE_ID   --no-source-dest-check
aws ec2 create-route   --route-table-id rtb-994449fc   --destination-cidr-block 10.1.0.0/16   --instance-id $INSTANCE_ID
```

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml

helm search repo eks/aws-load-balancer-controller --versions
helm repo add eks https://aws.github.io/eks-charts
helm repo update
 helm install aws-load-balancer-controller eks/aws-load-balancer-controller --version 3.0.0 -n kube-system -f values.yml
```

```
kubectl get targetgroupbindings -n shyam
kubectl get targetgroup -A
kubectl get node aws-elb-master -o jsonpath='{.spec.providerID}'
kubectl rollout restart deployment aws-load-balancer-controller -n kube-system
kubectl rollout status deployment aws-load-balancer-controller -n kube-system

kubectl patch gateway nginx-alb-gateway -n default -p '{"metadata":{"finalizers":null}}' --type=merge

```




```bash
# Check annotations (where providerID lives)
kubectl get node root-master-nginx-ingress-172-34-8-79 \
  -o jsonpath='{.metadata.annotations.providerID}{"\n"}'

# Or full node details
kubectl describe node root-master-nginx-ingress-172-34-8-79 | grep providerID

```

### add this label addition on worker


```bash
###nginx api gateway
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

````


```bash
sudo systemctl status snap.k8s.etcd.service
##### cleangign already joined data fo cluster
sudo rm -rf /var/snap/k8s/common/var/lib/etcd/data

curl -k https://172.34.30.20:6400
########### cleaning cluster join config
sudo rm -rf /var/snap/k8s/common/var/lib/k8sd/state/*

## remove older master nodes from here
sudo vi /var/snap/k8s/common/var/lib/k8sd/state/database/cluster.yaml

```

delete folder older than 30 days
```
find . -mindepth 1 -maxdepth 1 -type d -mtime +90 -exec rm -rf {} \; 

```
argocd

| Helm Chart | Argo CD Version | Status                               |
| ---------- | --------------- | ------------------------------------ |
| 5.26.x     | v2.2.5          | ✅ Most stable - Pre-parallelism bugs |
| 5.15.x     | v2.1.8          | ✅ Very stable, basic features        |
| 6.1.x      | v2.4.9          | ✅ Post-fixes but pre-major leaks     |



```bash
helm install argo-cd argo/argo-cd --namespace argocd --create-namespace --versions v2.14.11 -f values.yml
helm install v1-argo-cd argo/argo-cd --namespace argocd --create-namespace --version  7.9.1 -f values.yml
helm search repo argo/argo-cd --versions | grep 5.26.
 helm search repo argo/argo-cd --versions | grep 2.2.5




kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl rollout restart deployment/argocd-repo-server -n argocd
kubectl rollout status deployment/argocd-repo-server -n argocd



NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
argo-cd                 argocd          2               2026-01-27 06:51:09.36923777 +0000 UTC  deployed        argo-cd-9.3.6           v3.2.6


```


```bash
kubectl patch svc argo-cd-argocd-redis -n argocd -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch svc argo-cd-argocd-repo-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
######### stable app version 3.2.3  (9.2.4 is best chart )
 helm search repo argo/argo-cd --versions | grep 3.2.3
helm install argo-cd argo/argo-cd --namespace argocd --create-namespace --version  9.3.0 -f values.yml
helm upgrade argo-cd argo/argo-cd --namespace argocd --create-namespace --version  9.2.4 -f values.yml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
kubectl port-forward --address 0.0.0.0 -n argocd  svc/argocd-server 8080:443
#############
### manifest 3.2.2

curl 10.152.183.167:8084/healthz?full=true

kubectl exec -n kube-system cilium-x72x2 -- cilium status

kubectl patch gateway nginx-alb-gateway -n default -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings.elbv2.k8s.aws k8s-shyam-shyamrou-ffbde76f4a \
  -n shyam \
  -p '{"metadata":{"finalizers":null}}' --type=merge

```

ingress
```bash
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: argocd-allow-all-ingress
  namespace: argocd
spec:
  podSelector: {}  # ALL ArgoCD pods
  policyTypes:
  - Ingress
  ingress:
  - {}  # Allow ALL ports, ALL sources
EOF

```


```bash
kubectl get networkpolicies.networking.k8s.io -n argocd
NAME                                              POD-SELECTOR                                              AGE
argocd-allow-all-ingress                          <none>                                                    84s
argocd-application-controller-network-policy      app.kubernetes.io/name=argocd-application-controller      38m
argocd-applicationset-controller-network-policy   app.kubernetes.io/name=argocd-applicationset-controller   38m
argocd-dex-server-network-policy                  app.kubernetes.io/name=argocd-dex-server                  38m
argocd-notifications-controller-network-policy    app.kubernetes.io/name=argocd-notifications-controller    38m
argocd-redis-debug-allow-all                      app.kubernetes.io/name=argocd-redis                       4m8s
argocd-redis-network-policy                       app.kubernetes.io/name=argocd-redis                       38m
argocd-repo-server-network-policy                 app.kubernetes.io/name=argocd-repo-server                 38m
argocd-server-network-policy                      app.kubernetes.io/name=argocd-server                      38m

```