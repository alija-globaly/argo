#!/bin/bash

# Log file path
LOG_FILE="/var/log/superadmin-cron.log"

if ! sudo test -f "$LOG_FILE"; then
    sudo touch "$LOG_FILE"
    sudo chmod 777 "$LOG_FILE"
fi

# Get current timestamp at the start
START_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages with fresh timestamp
log_message() {
    CURRENT_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$CURRENT_TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Start logging
log_message "========================================"
log_message "Starting tenant usage aggregation"

# Run the kubectl command with -it flags and use tee to both display and log
kubectl exec -n superadmin -it deployments/superadmin-backend-deployment -- php artisan tenants:aggregate-usage-parallel --batch-size=1 2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

# Log success or failure with updated timestamp
if [ $EXIT_CODE -eq 0 ]; then
    log_message "SUCCESS: Command executed successfully"
else
    log_message "FAILED: Command execution failed with exit code $EXIT_CODE"
    
    # Add specific error information
    case $EXIT_CODE in
        137)
            log_message "ERROR: Out of Memory (OOM) - Pod was killed by Kubernetes"
            ;;
        143)
            log_message "ERROR: Pod terminated (SIGTERM)"
            ;;
    esac
fi

log_message "Completed tenant usage aggregation"
log_message "========================================"
echo "" >> "$LOG_FILE"