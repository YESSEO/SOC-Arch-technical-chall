# SOC Architect Technical Challenge - Wazuh Docker Swarm Deployment

An Ansible-based automation project to deploy Wazuh on Docker Swarm with NFS persistent storage. Supports multi-node manager/worker architecture and automates swarm initialization, node joining, and NFS setup.

## Prerequisites

- 2 server nodes for the swarm setup.
- 1 server for playing the NFS storage role.

Before running the playbooks, ensure:

- Ansible >= 2.14
- Python >= 3.9
- Hosts accessible
- SSH configured on all hosts


## Inventory & Variables

- The inventory file defines `managers`, `workers`, and `data` nodes.
- Default variables are in `.env`

```ini
# Initial hostnames
SWARM_MANAGER_HOSTNAME=node01-swarm
SWARM_WORKER_HOSTNAME=node02-swarm
NFS_SERVER_HOSTNAME=node03-nfs_data

# Initial IP's
SWARM_MANAGER_IP=172.16.187.161
SWARM_WORKER_IP=172.16.187.162
NFS_SERVER_IP=172.16.187.164

# Initial the users with SUDO privileges
ANSIBLE_USER=ansible
```

the `build.sh` script insure the necessary files exists to deploy the setup

```bash
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

```