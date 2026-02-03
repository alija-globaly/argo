#!/bin/bash

########### reference : https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/install/custom-worker/

# Configuration Variables
DEFAULT_TAG=uncategorized-worker
#DEFAULT_K8S_MASTER_IP=172.34.28.208
DEFAULT_K8S_MASTER_IP=k8s-root-master.agentcis-staging.internal
K8S_MASTER_USER=ubuntu
LOG_FILE="/var/log/kubernetes.log"
K8S_KUBELET_CONFIG_FILE="/var/snap/k8s/common/args/kubelet"
K8S_KUBELET_BINARY_DIR="/usr/local/bin/credential-providers"
K8S_KUBELET_CONFIG_DIR="/etc/kubernetes/credential-provider"
K8S_KUBELET_AWS_CRED_BINARY_URL="https://globalyhub-kubernetes-aws-provider.s3.ap-southeast-2.amazonaws.com/v1.35.0/ecr-credential-provider-linux-amd64"
CONFIG_CHANGED=false
# Define color codes as global variables
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'


# Function to print initialization messages in blue
print_init() {
    local message="$1"
    printf "${COLOR_BLUE}%s${COLOR_RESET}\n" "$message"
}

# Function to print success messages in green
print_success() {
    local message="$1"
    printf "${COLOR_GREEN}%s${COLOR_RESET}\n" "$message"
}

# Function to print failure messages in red
print_fail() {
    local message="$1"
    printf "${COLOR_RED}%s${COLOR_RESET}\n" "$message"
}

# Function to print separator
print_separator() {
    echo "=========================================================================="
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  $0 -t,  default-worker"
    echo "  $0 --tag default-worker"
    echo "  $0 --tag default-worker --master 172.34.16.159"
    echo "  -h, --help          Show this help message"
}

user_input_function() {
    TAG="${DEFAULT_TAG}"
    K8S_MASTER_IP="${DEFAULT_K8S_MASTER_IP}"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -w|--worker)
                TAG="$2"
                shift 2
                ;;
            -t|--tag)
                TAG="$2"
                echo "User input recieved"
                print_init "Master : ${TAG}"
                shift 2
                ;;                
            -m|--master)
                K8S_MASTER_IP="$2"
                echo "User input recieved"
                print_init "Master IP: ${K8S_MASTER_IP}"
                shift 2
                ;;                
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done
}

k8s_master_health_check() {
    print_init "Checking master node health..."
    print_init "Checking master node health..."

    local max_attempts=80
    local attempt=1
    local health_check_passed=false

    # Loop for HTTP health check
    for i in $(seq 1 $max_attempts); do
        print_init "Attempt ${i}/${max_attempts}: Checking HTTP endpoint..."
        local http_code=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${K8S_MASTER_IP}:6400")

        if [[ "$http_code" == "200" ]]; then
            print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | attempt ${i} -> Master node is healthy (HTTP Status: 200)" | sudo tee -a ${LOG_FILE}
            health_check_passed=true
            break
        else
            print_fail "Master node unreachable (Status: ${http_code})" | sudo tee -a ${LOG_FILE}
            if [[ $i -eq $max_attempts ]]; then
                print_fail "Master node health check timeout after ${max_attempts} attempts"
                exit 1
            fi
            print_fail "[$(date '+%Y-%m-%d %H:%M:%S')] | attempt ${i}  ->  Master node health check timeout" | sudo tee -a ${LOG_FILE}
            print_init "Retrying in 20 seconds..."
            sleep 20
        fi
    done

    # If HTTP check didn't pass, exit
    if [[ "$health_check_passed" != true ]]; then
        print_fail "HTTP health check failed"
        exit 1
    fi
    # Add SSH host key to known_hosts before connectivity check
    print_init "Adding SSH host key to known_hosts..."
    ssh-keyscan -H "${K8S_MASTER_IP}" >> ~/.ssh/known_hosts 2>/dev/null
    if [[ $? -eq 0 ]]; then
        print_success "SSH host key added successfully"
    else
        print_fail "Warning: Could not add SSH host key (continuing anyway)"
    fi


    if timeout 5 ssh -q -o ConnectTimeout=5 "${K8S_MASTER_USER}@${K8S_MASTER_IP}" exit 2>/dev/null; then
        print_success "✓ SSH connectivity is fine"
    else
        print_fail "Unable to SSH on Master Node : ${K8S_MASTER_IP} , USER : ${K8S_MASTER_USER}"
        exit 1
    fi    
}


k8s_cluster_join() {
    print_init "installing dependencis"
    sudo apt update    
    sudo apt install -y unzip nfs-common dnsutils net-tools  amazon-ec2-utils

    print_init "Configuring hostname"
    HOST_POSTFIX=$(ip route get 1.1.1.1 | cut -d' ' -f7 | tr '.' '-')
    FINAL_HOSTNAME=${TAG}-${HOST_POSTFIX}
    print_fail "Hostname is ${FINAL_HOSTNAME}"
    sudo hostnamectl set-hostname ${FINAL_HOSTNAME}

    print_init "Generating token and joining cluster..."
    local token=$(ssh ${K8S_MASTER_USER}@${K8S_MASTER_IP} "sudo k8s get-join-token --worker")

    sudo k8s join-cluster "$token"
    print_init "Waiting 5 seconds for kubelet..."
    sleep 5

    if snap services k8s.kubelet | grep -q "active"; then
        print_success "Node successfully joined the cluster!"
        print_separator
    else
        print_fail "Failed to join cluster - kubelet is not active"
        exit 1
    fi
}

reloading_k8s_node() {
    local NODE_NAME=$(hostname)
    
    print_separator
    print_init "🔄 Reloading K8s node: $NODE_NAME"
    print_init "🔒 Cordon node (prevent new pods)"
    if [[ "$PROVIDER_CHANGED" == true ]]; then
        # disabling cordon on worker node
        #kubectl cordon "$NODE_NAME" || true
        print_init "🗑️ Force deleting node object"
        kubectl delete node "$NODE_NAME" --force --grace-period=0 || true
        sleep 5
    fi

    if ! sudo snap stop k8s; then
        print_fail "Failed to stop k8s. Continuing with start attempt."
    fi

    # Attempt to start K8s
    if sudo snap start k8s; then
        # Check K8s status to ensure it started correctly
        print_init "Checking K8s status"
        if sudo k8s status --wait-ready >/dev/null; then
            print_success "K8s restarted successfully"
        else
            print_fail "K8s failed to reach ready state"
            print_fail "Please check logs with 'K8s inspect' or contact support"
            return 1
        fi
    else
        print_fail "Failed to start K8s"
        print_fail "Please check logs with 'K8s inspect' or contact support"
        return 1
    fi

}
add_kubectl_auto_completion() {
    echo "----------------------"
    if ! dpkg -l | grep -q bash-completion; then
        sudo apt install -y bash-completion
    fi

    # Add kubectl completion to .bashrc if missing
    if ! grep -q "kubectl completion bash" ~/.bashrc; then
        print_init "Configuring kubectl completion"
        echo 'source <(kubectl completion bash)' >> ~/.bashrc
        source ~/.bashrc
        print_success "kubectl completion configured"
    fi  

    # Add helm completion to .bashrc if missing
    if ! grep -q "helm completion bash" ~/.bashrc; then
        echo "Configuring helm completion..."
        echo 'source <(helm completion bash)' >> ~/.bashrc
        source ~/.bashrc
        echo "helm completion configured"
    fi  

    if [ ! -f ~/.kube/config ]; then
        echo "Configuring kubectl config..."
        mkdir -p ~/.kube
        # for master
        #sudo k8s config > ~/.kube/config
        ##for worker
        scp ${K8S_MASTER_USER}@${K8S_MASTER_IP}:/home/ubuntu/.kube/config $HOME/.kube/config
        echo "kubectl config created"
    fi

    if ! grep -q "KUBECONFIG=~/.kube/config" ~/.bashrc; then
    echo "Configuring KUBECONFIG..."
    echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
    source ~/.bashrc
    echo "KUBECONFIG configured"
    fi

}

directory_create() {
    print_init "Creating credential provider directories..."
    if sudo mkdir -p "${K8S_KUBELET_CONFIG_DIR}" "${K8S_KUBELET_BINARY_DIR}"; then
        sudo chmod 755 "${K8S_KUBELET_CONFIG_DIR}"
        sudo chmod 755 "${K8S_KUBELET_BINARY_DIR}"
        print_success "Directories created successfully"
    fi
}

kubelet_binary_setup() {
    print_init "Checking if ECR credential provider binary exists..."

    if sudo test -f "${K8S_KUBELET_BINARY_DIR}/ecr-credential-provider"; then
        print_success "ECR credential provider binary already exists"
    else
        print_init "Downloading ECR credential provider binary..."
        sudo curl -sSL "${K8S_KUBELET_AWS_CRED_BINARY_URL}" | sudo tee "${K8S_KUBELET_BINARY_DIR}/ecr-credential-provider" > /dev/null
        sudo chmod +x "${K8S_KUBELET_BINARY_DIR}/ecr-credential-provider"
        print_success "Binary downloaded and made executable"
        CONFIG_CHANGED=true
    fi

    local version=$(sudo "${K8S_KUBELET_BINARY_DIR}/ecr-credential-provider" --version 2>&1)
    print_success "Version: ${version}"
}

kubelet_ecr_config_generate() {
    local config_file="${K8S_KUBELET_CONFIG_DIR}/config.yaml"

    print_init "Checking if kubelet config file exists..."

    if sudo test -f "$config_file"; then
        print_success "Config file already exists: $config_file"
        print_success "Skipping config file creation"
    else
        print_init "Creating kubelet credential provider config..."
        sudo tee "$config_file" > /dev/null <<EOF
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
        print_success "Config file created successfully"
        CONFIG_CHANGED=true
    fi
}

# Function to configure kubelet credential provider arguments
kubelet_k8s_args_update() {
    local kubelet_bin_search="--image-credential-provider-bin-dir=${K8S_KUBELET_BINARY_DIR}"
    local kubelet_config_search="--image-credential-provider-config=${K8S_KUBELET_CONFIG_DIR}/config.yaml"
    ################################# BInary directory record check #####################################
    print_init "Checking kubelet credential provider configuration..."
    if sudo grep -q "^--image-credential-provider-bin-dir=" "${K8S_KUBELET_CONFIG_FILE}" 2>/dev/null; then
        if ! sudo grep -q "^${kubelet_bin_search}$" "${K8S_KUBELET_CONFIG_FILE}"; then
            print_init "Updating credential provider bin directory..."
            sudo sed -i "s|^--image-credential-provider-bin-dir=.*|${kubelet_bin_search}|" "${K8S_KUBELET_CONFIG_FILE}"
            CONFIG_CHANGED=true
        fi
    else
        print_init "Adding credential provider bin directory..."
        echo "$kubelet_bin_search" | sudo tee -a "${K8S_KUBELET_CONFIG_FILE}" > /dev/null
        CONFIG_CHANGED=true
    fi
    ################################# config directory check #####################################
    if sudo grep -q "^--image-credential-provider-config=" "${K8S_KUBELET_CONFIG_FILE}" 2>/dev/null; then
        if ! sudo grep -q "^${kubelet_config_search}$" "${K8S_KUBELET_CONFIG_FILE}"; then
            print_init "Updating credential provider config path..."
            sudo sed -i "s|^--image-credential-provider-config=.*|${kubelet_config_search}|" "${K8S_KUBELET_CONFIG_FILE}"
            CONFIG_CHANGED=true
        fi
    else
        print_init "Adding credential provider config path..."
        echo "$kubelet_config_search" | sudo tee -a "${K8S_KUBELET_CONFIG_FILE}" > /dev/null
        CONFIG_CHANGED=true
    fi
    ################################### Testing config updated or not ##############################
    if [[ "CONFIG_CHANGED" == true ]]; then
        print_success "Kubelet configuration updated"
    else
        print_success "Kubelet configuration already correct"
    fi
}

kubelet_aws_provider_setup() {
    print_separator
    print_init "Configuring AWS ProviderID for Load Balancer Controller..."
     
    # Get AWS metadata
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)
    
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
      http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)
    
    PROVIDER_ID="aws:///${AZ}/${INSTANCE_ID}"
    print_init "Detected: AZ=${AZ}, Instance=${INSTANCE_ID}"
    
    # Check if provider-id arg exists
    if sudo grep -q "^--provider-id=" "$K8S_KUBELET_CONFIG_FILE" 2>/dev/null; then
        CURRENT_PROVIDER=$(sudo grep "^--provider-id=" "$K8S_KUBELET_CONFIG_FILE" | awk -F'=' '{print $2}' | head -n1 | tr -d ' ')
        if [[ "$CURRENT_PROVIDER" == "$PROVIDER_ID" ]]; then
            print_success "✅ ProviderID already correct: $PROVIDER_ID"
        else
            print_init "⚠️ Updating ProviderID: $CURRENT_PROVIDER → $PROVIDER_ID"
            sudo sed -i "s|^--provider-id=.*|--provider-id=${PROVIDER_ID}|" "$K8S_KUBELET_CONFIG_FILE"
            PROVIDER_CHANGED=true
        fi
    else
        print_init "➕ Adding ProviderID to kubelet args"
        echo "--provider-id=${PROVIDER_ID}" | sudo tee -a "$K8S_KUBELET_CONFIG_FILE" >/dev/null
        PROVIDER_CHANGED=true
    fi
    
    # SAFE ProviderID verification (no node deletion for single-node clusters)
    if kubectl get nodes >/dev/null 2>&1; then
        NODE_NAME=$(hostname)
        sleep 5  # Give kubelet time to register
        
        if kubectl get node "$NODE_NAME" -o jsonpath='{.spec.providerID}' | grep -q "aws:///"; then
            print_success "✅ Node registered with ProviderID: $(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.providerID}')"
        else
            print_init "ℹ️ ProviderID pending kubelet registration (normal after restart)"
            PROVIDER_CHANGED=true  # Ensure restart happens
        fi
    else
        print_init "ℹ️ Cluster not ready - ProviderID will register after restart"
        PROVIDER_CHANGED=true
    fi    
    print_separator
}

restart_k8s_service() {
    print_separator
    print_init "Restarting k8s service..."

    sudo snap restart k8s
    sleep 5

    if sudo snap services k8s | grep -q "active"; then
        print_success "k8s restarted successfully"
    else
        print_fail "k8s service is not active after restart"
        print_fail "Check logs: snap logs k8s"
        exit 1
    fi
}

install_aws_cli() {
  if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI is already installed."
    aws --version
    return 0
  fi

  echo "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&
  unzip -q awscliv2.zip &&
  sudo ./aws/install --bin-dir /usr/local/bin -i /usr/local/aws-cli &&
  rm -rf aws awscliv2.zip &&
  echo "AWS CLI installed successfully!" &&
  aws --version
}

# Main function
main() {
    user_input_function "$@"
    k8s_master_health_check
    k8s_cluster_join
    install_aws_cli
    add_kubectl_auto_completion
    directory_create
    kubelet_binary_setup
    kubelet_ecr_config_generate
    kubelet_k8s_args_update
    kubelet_aws_provider_setup
    if [[ "$CONFIG_CHANGED" == true || "$PROVIDER_CHANGED" == true ]]; then
        reloading_k8s_node
    else
        print_success "No configuration changes detected. Skipping K8s restart"
    fi
    
    print_separator
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | All tasks completed successfully!" | sudo tee -a ${LOG_FILE}
    print_init "==============================================" | sudo tee -a ${LOG_FILE}
    print_separator

    # Unset all variables
    unset K8S_KUBELET_CONFIG_DIR
    unset K8S_KUBELET_BINARY_DIR
    unset K8S_KUBELET_CONFIG_FILE
    unset K8S_KUBELET_AWS_CRED_BINARY_URL
    unset CREDENTIAL_PROVIDER_CONFIG_SOURCE
    unset CONFIG_CHANGED
    unset COLOR_GREEN
    unset COLOR_RED
    unset COLOR_BLUE
    unset COLOR_RESET
}

main "$@"
