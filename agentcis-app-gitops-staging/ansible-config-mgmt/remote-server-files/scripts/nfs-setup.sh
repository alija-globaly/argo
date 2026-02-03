#!/bin/bash

# Default Directories and Network
NFS_CONFIG_DIR="/k8s-config-volume"
NFS_LOG_DIR="/k8s-log-volume"
NFS_NETWORK="192.168.253.0/24"
LOG_FILE="/var/log/nfs-server.log"
CONFIG_CHANGED=false
FUNCTION_COUNT=0

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
    print_success "Usage: $script_name"
    echo "Options:"
    echo "  No arguments required. Installs NFS server with config-volume and log-volume"
    echo "  Exports both volumes to ${NFS_NETWORK}"
    printf "\n"
    print_fail "Examples:"
    print_init "  $script_name"
    printf "\n"
    print_fail "Contact and Support"
    echo -n "   Email:   "
    print_success "subash.chaudhary@globalyhub.com"
    echo -n "   Phone:   "
    print_success "+977 9823827047"
    exit 1
}

initial_setup_dependency() {
    ((FUNCTION_COUNT++))
    print_init "[$(date '+%Y-%m-%d %H:%M:%S')] | function ${FUNCTION_COUNT} : Initial setup dependency Start" | sudo tee -a ${LOG_FILE}
    
    print_init "Updating system packages..."
    sudo apt update
    sudo apt install -y unzip nfs-common dnsutils net-tools amazon-ec2-utils

    if dpkg -l | grep -q nfs-kernel-server; then
        print_success "NFS Server is already installed"
        sudo systemctl status nfs-kernel-server.service --no-pager >/dev/null 2>&1
    else
        sudo apt install -y nfs-kernel-server
        print_success "NFS Server installed successfully"
        CONFIG_CHANGED=true
    fi
        
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | Initial setup dependency Finish" | sudo tee -a ${LOG_FILE}
}


create_nfs_directories() {
    ((FUNCTION_COUNT++))
    print_init "[$(date '+%Y-%m-%d %H:%M:%S')] | function ${FUNCTION_COUNT} : Creating NFS directories Start" | sudo tee -a ${LOG_FILE}
    
    print_separator
    print_init "Creating NFS directories: ${NFS_CONFIG_DIR} and ${NFS_LOG_DIR}"
    
    if sudo mkdir -p "${NFS_CONFIG_DIR}" "${NFS_LOG_DIR}"; then
        sudo chown nobody:nogroup "${NFS_CONFIG_DIR}"
        sudo chown nobody:nogroup "${NFS_LOG_DIR}"
        sudo chmod 777 "${NFS_CONFIG_DIR}"
        sudo chmod 777 "${NFS_LOG_DIR}"
        print_success "Directories created and permissions set successfully"
        CONFIG_CHANGED=true
    else
        print_fail "Failed to create directories"
        return 1
    fi
    
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | Creating NFS directories Finish" | sudo tee -a ${LOG_FILE}
}

configure_exports_file() {
    ((FUNCTION_COUNT++))
    print_init "[$(date '+%Y-%m-%d %H:%M:%S')] | function ${FUNCTION_COUNT} : Configuring exports file Start" | sudo tee -a ${LOG_FILE}
    
    print_separator
    print_init "Configuring /etc/exports file..."
    
    local exports_content="/etc/exports"
    local config_entry="${NFS_CONFIG_DIR} ${NFS_NETWORK}(rw,sync,no_subtree_check)"
    local log_entry="${NFS_LOG_DIR} ${NFS_NETWORK}(rw,sync,no_subtree_check)"
    
    # Check if entries already exist
    if sudo grep -q "^${NFS_CONFIG_DIR}" /etc/exports 2>/dev/null &&
       sudo grep -q "^${NFS_LOG_DIR}" /etc/exports 2>/dev/null; then
        print_success "Export entries already exist in /etc/exports"
    else
        print_init "Adding export entries to /etc/exports"
        
        # Backup existing exports file
        sudo cp /etc/exports /etc/exports.backup.$(date +%Y%m%d_%H%M%S)
        
        # Create new exports content
        {
            echo "# NFS Server Configuration - $(date)"
            echo "# Config Volume"
            echo "${config_entry}"
            echo "# Log Volume" 
            echo "${log_entry}"
            echo ""
            echo "# Previous configuration (backup)"
            sudo cat /etc/exports.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo "# No previous config"
        } | sudo tee /etc/exports > /dev/null
        
        print_success "Export entries added successfully"
        CONFIG_CHANGED=true
    fi
    
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | Configuring exports file Finish" | sudo tee -a ${LOG_FILE}
}


apply_exports_changes() {
    ((FUNCTION_COUNT++))
    print_init "[$(date '+%Y-%m-%d %H:%M:%S')] | function ${FUNCTION_COUNT} : Applying exports changes Start" | sudo tee -a ${LOG_FILE}
    
    print_separator
    print_init "Applying NFS export changes..."
    
    if sudo exportfs -a; then
        print_success "Exportfs applied successfully"
        
        # Restart service if configuration changed
        if [[ "$CONFIG_CHANGED" == true ]]; then
            print_init "Restarting NFS service to apply changes..."
            sudo systemctl restart nfs-kernel-server.service
            
            if sudo systemctl is-active --quiet nfs-kernel-server.service; then
                print_success "NFS service restarted successfully"
            else
                print_fail "NFS service failed to restart"
                return 1
            fi
        fi
    else
        print_fail "Failed to apply exportfs changes"
        return 1
    fi
    
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | Applying exports changes Finish" | sudo tee -a ${LOG_FILE}
}

verify_nfs_setup() {
    ((FUNCTION_COUNT++))
    print_init "[$(date '+%Y-%m-%d %H:%M:%S')] | function ${FUNCTION_COUNT} : Verifying NFS setup Start" | sudo tee -a ${LOG_FILE}
    
    print_separator
    print_init "Verifying NFS setup..."
    
    # Check service status
    if sudo systemctl is-active --quiet nfs-kernel-server.service; then
        print_success "✅ NFS service is active"
    else
        print_fail "❌ NFS service is not active"
        return 1
    fi
    
    # Check directories exist
    if sudo test -d "${NFS_CONFIG_DIR}" && sudo test -d "${NFS_LOG_DIR}"; then
        print_success "✅ Directories exist: ${NFS_CONFIG_DIR}, ${NFS_LOG_DIR}"
    else
        print_fail "❌ Directories missing"
        return 1
    fi
    
    # Check exports
    if sudo grep -q "${NFS_NETWORK}" /etc/exports; then
        print_success "✅ Exports configured for ${NFS_NETWORK}"
        print_init "Export details:"
        sudo exportfs -v | grep "${NFS_NETWORK}"
    else
        print_fail "❌ Network export not found"
        return 1
    fi
    
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | Verifying NFS setup Finish" | sudo tee -a ${LOG_FILE}
}

show_nfs_status() {
    print_separator
    print_success "🎉 NFS Server Setup Complete!"
    print_init "📁 Config Volume: ${NFS_CONFIG_DIR}"
    print_init "📁 Log Volume: ${NFS_LOG_DIR}"
    print_init "🌐 Network: ${NFS_NETWORK}"
    print_init ""
    print_init "🔍 Useful Commands:"
    print_init "  sudo systemctl status nfs-kernel-server.service"
    print_init "  sudo exportfs -v"
    print_init "  showmount -e localhost"
    print_init "  sudo tail -f ${LOG_FILE}"
    print_separator
}

# Main function
main() {
    # Create log file if not exists
    sudo touch ${LOG_FILE}
    sudo chmod 644 ${LOG_FILE}
    
    print_separator
    print_init "[$(date '+%Y-%m-%d %H:%M:%S')] | NFS Server Installation Started" | sudo tee -a ${LOG_FILE}
    
    initial_setup_dependency
    install_nfs_server
    create_nfs_directories
    configure_exports_file
    manage_nfs_service
    apply_exports_changes
    verify_nfs_setup
    
    show_nfs_status
    
    print_separator
    print_success "[$(date '+%Y-%m-%d %H:%M:%S')] | All tasks completed successfully!" | sudo tee -a ${LOG_FILE}
    print_init "==============================================" | sudo tee -a ${LOG_FILE}
    print_separator

    # Unset all variables
    unset NFS_CONFIG_DIR
    unset NFS_LOG_DIR
    unset NFS_NETWORK
    unset LOG_FILE
    unset CONFIG_CHANGED
    unset FUNCTION_COUNT
    unset COLOR_GREEN
    unset COLOR_RED
    unset COLOR_YELLOW
    unset COLOR_RESET
}

main "$@"
