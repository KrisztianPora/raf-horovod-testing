#Cleans up any previous configuration, and configures Ansible to use the IP given as the argument $1 as a proxy for SSH connections.

#!/bin/bash

rm -rf /etc/ansible
mkdir -p /etc/ansible
echo "[ssh_connection]" >> /etc/ansible/ansible.cfg
echo "ssh_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p ubuntu@$1\"'" >> /etc/ansible/ansible.cfg
