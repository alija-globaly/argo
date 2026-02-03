#!/bin/bash

# Define color codes as global variables
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
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

# Function to print info messages in blue
print_info() {
    local message="$1"
    printf "${COLOR_BLUE}%s${COLOR_RESET}\n" "$message"
}

# Function to print separator
print_separator() {
    echo "=========================================================================="
}

# Function to check if Docker is installed
check_docker_installed() {
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null | awk '{print $3}' | sed 's/,//')
        print_success "Docker is already installed: $DOCKER_VERSION"
        return 0
    else
        print_info "Docker is not installed."
        return 1
    fi
}

# Function to check if Docker Compose is installed
check_docker_compose_installed() {
    if docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version 2>/dev/null | awk '{print $4}')
        print_success "Docker Compose is already installed: $COMPOSE_VERSION"
        return 0
    else
        print_info "Docker Compose is not installed."
        return 1
    fi
}

# Function to check if user is in docker group
check_user_in_docker_group() {
    if groups $USER | grep -q '\bdocker\b'; then
        print_success "User '$USER' is already in the docker group."
        return 0
    else
        print_info "User '$USER' is not in the docker group."
        return 1
    fi
}

# Function to setup Docker prerequisites
pre_requirements_setup() {
    print_separator
    print_init "Setting up Docker prerequisites..."
    print_separator
    sudo apt update -y
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        print_init "Adding Docker's GPG key..."
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        print_success "Docker GPG key added successfully."
    else
        print_success "Docker GPG key already exists."
    fi
    
    if [ ! -f /etc/apt/sources.list.d/docker.sources ]; then
        print_init "Adding Docker repository..."
        sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
        print_success "Docker repository added successfully."
    else
        print_success "Docker repository already exists."
    fi
    sudo apt update -y
}

install_docker() {
    print_separator
    print_init "Installing Docker and Docker Compose..."
    print_separator

    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    if [ $? -eq 0 ]; then
        print_success "Docker and Docker Compose installed successfully!"
        docker --version
        docker compose version
    else
        print_fail "Failed to install Docker and Docker Compose."
        exit 1
    fi
}

# Function to perform post-installation steps
docker_post_install() {
    print_separator
    print_init "Performing Docker post-installation steps..."
    print_separator

    if ! check_user_in_docker_group; then
        print_init "Adding user '$USER' to docker group..."
        sudo usermod -aG docker $USER
        print_success "User '$USER' added to docker group."
        print_info "Please log out and log back in for group changes to take effect."
        print_info "Or run: newgrp docker"
    fi

    print_init "Enabling and starting Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker

    if systemctl is-active --quiet docker; then
        print_success "Docker service is running."
    else
        print_fail "Docker service failed to start."
        exit 1
    fi
}

verify_docker_installation() {
    print_separator
    print_init "Verifying Docker installation..."
    print_separator

    # Test Docker
    if docker run hello-world &> /dev/null; then
        print_success "Docker is working correctly!"
    else
        print_fail "Docker test failed. You may need to log out and log back in."
    fi

    # Display Docker info
    print_separator
    print_info "Docker System Information:"
    docker info | grep -E "Server Version|Storage Driver|Cgroup Driver|Kernel Version"
    print_separator
}

main() {
    print_separator
    print_init "Docker Installation Script for Ubuntu"
    print_separator

    # Check current installation status
    DOCKER_INSTALLED=false
    COMPOSE_INSTALLED=false
    USER_IN_GROUP=false

    if check_docker_installed; then
        DOCKER_INSTALLED=true
    fi

    if check_docker_compose_installed; then
        COMPOSE_INSTALLED=true
    fi

    if check_user_in_docker_group; then
        USER_IN_GROUP=true
    fi

    # Determine what needs to be done
    if [[ "$DOCKER_INSTALLED" == true ]] && [[ "$COMPOSE_INSTALLED" == true ]]; then
        print_success "Docker and Docker Compose are already installed."
        
        if [[ "$USER_IN_GROUP" == false ]]; then
            print_init "Performing post-installation configuration..."
            docker_post_install
        else
            print_success "All Docker setup is complete. Nothing to do."
        fi
    else
        # Install Docker if not present
        print_init "Docker installation required. Proceeding with installation..."
        pre_requirements_setup
        install_docker
        docker_post_install
        verify_docker_installation
    fi

    print_separator
    print_success "Script execution completed!"
    print_separator

    # Unset all variables
    unset COLOR_GREEN
    unset COLOR_RED
    unset COLOR_YELLOW
    unset COLOR_BLUE
    unset COLOR_RESET
    unset DOCKER_INSTALLED
    unset COMPOSE_INSTALLED
    unset USER_IN_GROUP
    unset DOCKER_VERSION
    unset COMPOSE_VERSION
}
main "$@"