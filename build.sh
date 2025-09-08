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

# Building docker compose
compose_base="docker/wazuh-docker/multi-node/docker-compose.yml"
compose_template=$(realpath "./docker/templates/docker-compose.yml")
if [ -e "$compose_template" ]; then
    # Generating docker-compose.yml
    envsubst < "$compose_template" > "$compose_base"
    # Overwrite the originale docker compose
    echo "[INFO] Docker Compose generated at ./$compose_base"
else
    echo "[ERROR] Make sure the Docker Compose template file exists..."
    exit 1
fi


file="./ansible/group_vars/all.yml"
base_dir="$PWD"

if [ ! -f "$file" ]; then
  echo "[ERROR] File not found: $file" >&2
  exit 1
fi

if grep -q '^base_dir:' "$file"; then
  sed -i "s|^base_dir:.*|base_dir: ${base_dir}|" "$file"
else
  echo "base_dir: ${base_dir}" >> "$file"
fi

echo "[INFO] base_dir set to: $base_dir in $file"

# Run ansible
ansible-playbook -i ansible/inventory.ini ansible/playbooks/sites.yaml --ask-become

# Wazuh Stack
ansible-playbook -i ansible/inventory.ini ansible/playbooks/wazuh_stack.yaml --ask-become

