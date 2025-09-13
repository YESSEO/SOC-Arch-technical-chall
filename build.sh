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

# Building ansible var file
ansible_vars_example=$(realpath "./ansible/group_vars/all_template.yml")
ansible_vars="$PWD/ansible/group_vars/all.yml"

if [ ! -f "$ansible_vars_example" ]; then
  echo "[ERROR] File not found: $ansible_vars_example" >&2
  exit 1
else 
	envsubst < "$ansible_vars_example" > "$ansible_vars"
        echo "[INFO] Vars file generated at $ansible_vars"
fi
 
ansible-playbook -i ansible/inventory.ini --ask-become --ask-vault-pass \
	ansible/playbooks/trivy.yaml \
	ansible/playbooks/sites.yaml \
	ansible/playbooks/wazuh_stack.yaml
