#!/bin/bash

# Checking if .env exists
env_file=$(realpath ".env")
if [ -e "$env_file" ]; then
    # Loading vars
    set -a && source "$env_file" && set +a

    # Safely get the Ansible inventory template
    inventory_template=$(realpath "./ansible/templates/inventory.template.ini")
    if [ -e "$inventory_template" ]; then
        # Generating inventory.ini
        envsubst < "$inventory_template" > "./ansible/inventory.ini"
        echo "[INFO] Inventory generated at ./ansible/inventory.ini"
    else
        echo "[ERROR] Make sure the Ansible inventory template file exists..."
        exit 1
    fi
else 
    echo "[ERROR] The environment file is missing..."
    exit 1
fi

ansible-playbook -i ansible/inventory.ini ansible/playbooks/sites.yaml --ask-become -vvv
