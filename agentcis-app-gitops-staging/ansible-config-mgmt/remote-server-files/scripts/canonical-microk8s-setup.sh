#!/bin/bash

####### reference : https://ubuntu.com/kubernetes/install

# Default Services and Directory
K8S_CONFIG_DIR="$HOME/.kube"
K8S_TOKEN_FILE="$HOME/k8s-default/k8s_token.txt"
K8S_SERVICE_FILE="/var/snap/microk8s/current/args/kube-apiserver"
K8S_CONTROLLER_FILE="/var/snap/microk8s/current/args/kube-controller-manager"
DASHBOARD_CONFIG_DIR="$HOME/k8s-default"
CONFIG_CHANGED=false

# Define color codes as global variables
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_RESET='\033[0m'

# Initialization in Yellow color
print_init() {
    local message="$1"
    printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "$message"
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

# Function to print usage information
user_help_function() {
    local script_name="$0"
    printf "\n\n"
    print_success "Usage: $script_name [-s <service1,service2,...>] [-d <log_directory>]"
    echo "Options:"
    echo "  -s, --service <service1,service2,...>  Comma-separated list of services to check"
    echo "  -d, --directory <log_directory>        Optional: Directory where log file will be stored"
    echo
    print_fail "Examples:"
    print_init "  $script_name -s nginx.service,supervisor.service"
    print_init "  $script_name -s nginx.service -d /path/to/logdir"
    printf "\n"
    print_fail "Contact and Support"
    echo -n "   Email:   "
    print_success "subash.chaudhary@globalyhub.com"
    echo -n "   Phone:   "
    print_success "+977 9823827047"
    exit 1
}

dependency_installation() {
    # Check if microk8s is already installed
    if ! command -v microk8s &> /dev/null; then
        print_init "Installing Kubernetes (microk8s)"
        sudo apt update
        sudo snap install microk8s --classic --channel=1.32
    else
        print_success "microk8s is already installed. Skipping installation."
    fi

    # Check if Kubernetes config directory exists
    if [[ ! -d "${K8S_CONFIG_DIR}" ]]; then
        mkdir -p "${K8S_CONFIG_DIR}"
        chmod 0700 "${K8S_CONFIG_DIR}"
        echo "Created config log directory: ${K8S_CONFIG_DIR}"
        print_separator
    else
        print_success "K8s config directory: ${K8S_CONFIG_DIR} already exists"
    fi

    print_init "User-config-setup"
    sudo usermod -a -G microk8s "$USER"
    sudo chown -R "$USER" "${K8S_CONFIG_DIR}"
}

add_kubectl_alias() {
    echo "----------------------"
    print_init "Configuring kubectl alias"
    local alias_cmd="alias kubectl='microk8s kubectl'"
    local bashrc_file="$HOME/.bashrc"

    # Check if alias already exists in .bashrc
    if grep -Fx "$alias_cmd" "$bashrc_file" > /dev/null; then
        print_success "kubectl alias already exists in $bashrc_file. Skipping."
    else
        # Append alias to .bashrc
        echo "$alias_cmd" >> "$bashrc_file"
        print_success "Added kubectl alias to $bashrc_file"
        # Source .bashrc to apply the alias in the current session
        if source "$bashrc_file"; then
            print_success "Sourced $bashrc_file to apply kubectl alias"
        else
            print_fail "Failed to source $bashrc_file. Please run 'source ~/.bashrc' or restart your terminal to apply the alias"
        fi
    fi
    echo "----------------------"
}

enabling_add_ons() {
    print_init "Enabling some basic essential features of K8s"
    microk8s enable dns
    microk8s enable hostpath-storage
    microk8s enable metrics-server
    microk8s enable dashboard
    print_success "All essential add-ons services are enabled"

    print_init "Initializing token for dashboard"
    local token
    token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
    microk8s kubectl -n kube-system describe secrets -n kube-system | grep -i "token:" | awk -F ' ' '{print $2}' > "${K8S_TOKEN_FILE}"
    print_success "Token is saved at file: ${K8S_TOKEN_FILE}"
}

updating_service_port_range() {
    echo "----------------------"
    print_init "Test 1: Updating Service Port Range"
    local service_file="${K8S_SERVICE_FILE}"
    if [[ ! -f "${service_file}" ]]; then
        print_fail "API service-file config is not found at ${service_file}"
        echo "----------------------"
        return 1
    else
        print_success "File found. Testing service-port-range"
        if grep -q "service-node-port-range" "${service_file}"; then
            local current_port_range
            current_port_range=$(grep "service-node-port-range" "${service_file}" | awk -F '=' '{print $2}' | tr -d ' ')
            print_init "Current port range: ${current_port_range}"

            if [[ "${current_port_range}" == "1025-65534" ]]; then
                print_success "Port is already configured correctly"
            else
                print_fail "Unexpected port range configuration: ${current_port_range}"
                print_init "Updating port range to 1025-65534"
                sed -i "s|service-node-port-range=.*|service-node-port-range=1025-65534|" "${service_file}"
                print_success "Port range updated to 1025-65534"
                CONFIG_CHANGED=true
            fi
        else
            print_fail "No port range configuration found"
            print_init "Adding service-node-port-range=1025-65534 to the configuration"
            echo "--service-node-port-range=1025-65534" >> "${service_file}"
            print_success "Port range configuration added: 1025-65534"
            CONFIG_CHANGED=true
        fi
    fi
    echo "----------------------"
}

kube_proxy_cidr_update() {
    echo "----------------------"
    print_init "Test 2: Updating Kube Proxy CIDR"
    local service_file="${K8S_SERVICE_FILE}"
    if [[ ! -f "${service_file}" ]]; then
        print_fail "API service-file config is not found at ${service_file}"
        echo "----------------------"
        return 1
    else
        print_success "File found. Testing service-cluster-ip-range"
        if grep -q "service-cluster-ip-range" "${service_file}"; then
            local current_cidr
            current_cidr=$(grep "service-cluster-ip-range" "${service_file}" | awk -F '=' '{print $2}' | tr -d ' ')
            print_init "Current CIDR range: ${current_cidr}"

            if [[ "${current_cidr}" == "10.152.0.0/16" ]]; then
                print_success "CIDR range is already configured correctly"
            else
                print_fail "Unexpected CIDR range configuration: ${current_cidr}"
                print_init "Updating CIDR range to 10.152.0.0/16"
                sed -i "s|service-cluster-ip-range=.*|service-cluster-ip-range=10.152.0.0/16|" "${service_file}"
                print_success "CIDR range updated to 10.152.0.0/16"
                CONFIG_CHANGED=true
            fi
        else
            print_fail "No CIDR range configuration found"
            print_init "Adding service-cluster-ip-range=10.152.0.0/16 to the configuration"
            echo "--service-cluster-ip-range=10.152.0.0/16" >> "${service_file}"
            print_success "CIDR range configuration added: 10.152.0.0/16"
            CONFIG_CHANGED=true
        fi
    fi
    echo "----------------------"
}

kube_controller_cidr_update() {
    echo "----------------------"
    print_init "Test 3: Updating Kube Controller CIDR"
    local controller_file="${K8S_CONTROLLER_FILE}"
    if [[ ! -f "${controller_file}" ]]; then
        print_fail "Controller manager config is not found at ${controller_file}"
        echo "----------------------"
        return 1
    else
        print_success "File found. Testing controller service-cluster-ip-range"
        if grep -q "service-cluster-ip-range" "${controller_file}"; then
            local current_cidr
            current_cidr=$(grep "service-cluster-ip-range" "${controller_file}" | awk -F '=' '{print $2}' | tr -d ' ')
            print_init "Current controller CIDR range: ${current_cidr}"

            if [[ "${current_cidr}" == "10.152.0.0/16" ]]; then
                print_success "Controller CIDR range is already configured correctly"
            else
                print_fail "Unexpected controller CIDR range configuration: ${current_cidr}"
                print_init "Updating controller CIDR range to 10.152.0.0/16"
                sed -i "s|service-cluster-ip-range=.*|service-cluster-ip-range=10.152.0.0/16|" "${controller_file}"
                print_success "Controller CIDR range updated to 10.152.0.0/16"
                CONFIG_CHANGED=true
            fi
        else
            print_fail "No controller CIDR range configuration found"
            print_init "Adding service-cluster-ip-range=10.152.0.0/16 to the configuration"
            echo "--service-cluster-ip-range=10.152.0.0/16" >> "${controller_file}"
            print_success "Controller CIDR range configuration added: 10.152.0.0/16"
            CONFIG_CHANGED=true
        fi
    fi
    echo "----------------------"
}

restart_microk8s() {
    print_init "Restarting MicroK8s services"

    # Attempt to stop MicroK8s
    if ! microk8s stop; then
        print_fail "Failed to stop MicroK8s. Continuing with start attempt."
    fi

    # Attempt to start MicroK8s
    if microk8s start; then
        # Check MicroK8s status to ensure it started correctly
        print_init "Checking MicroK8s status"
        if microk8s status --wait-ready --timeout 60 >/dev/null; then
            print_success "MicroK8s restarted successfully"
        else
            print_fail "MicroK8s failed to reach ready state"
            print_fail "Please check logs with 'microk8s inspect' or contact support"
            return 1
        fi
    else
        print_fail "Failed to start MicroK8s"
        print_fail "Please check logs with 'microk8s inspect' or contact support"
        return 1
    fi
}

create_dashboard_service() {
    print_init "Creating Kubernetes Dashboard Service configuration"
    if [[ ! -d "${DASHBOARD_CONFIG_DIR}" ]]; then
        mkdir -p "${DASHBOARD_CONFIG_DIR}"
        print_success "Created directory: ${DASHBOARD_CONFIG_DIR}"
    fi
    cat > "${DASHBOARD_CONFIG_DIR}/dashboard-service.yml" << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard-nodeport
  namespace: kube-system
spec:
  selector:
    k8s-app: kubernetes-dashboard
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 18080
  type: NodePort
EOF

    print_success "Kubernetes Dashboard Service configuration created at: ${DASHBOARD_CONFIG_DIR}/dashboard-service.yml"
    print_init "Applying Kubernetes Dashboard Service configuration"
    if microk8s kubectl apply -f "${DASHBOARD_CONFIG_DIR}/dashboard-service.yml"; then
        print_success "Kubernetes Dashboard Service successfully applied"
    else
        print_fail "Failed to apply Kubernetes Dashboard Service configuration"
        return 1
    fi
}

# Main function
main() {
    sudo apt-get install -y nfs-common
    dependency_installation
    add_kubectl_alias
    enabling_add_ons
    updating_service_port_range
    kube_proxy_cidr_update
    kube_controller_cidr_update

    if [[ "$CONFIG_CHANGED" == true ]]; then
        restart_microk8s
    else
        print_success "No configuration changes detected. Skipping MicroK8s restart."
    fi

    create_dashboard_service

    # Unset all variables
    unset K8S_CONFIG_DIR
    unset K8S_TOKEN_FILE
    unset K8S_SERVICE_FILE
    unset K8S_CONTROLLER_FILE
    unset DASHBOARD_CONFIG_DIR
    unset CONFIG_CHANGED
    unset COLOR_GREEN
    unset COLOR_RED
    unset COLOR_YELLOW
    unset COLOR_RESET
}

main "$@"