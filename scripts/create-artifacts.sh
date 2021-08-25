#Generates the inventory and hostlist artifacts (text files).
#inventory is a list of all nodes (their IP addresses) grouped by their role (master, worker)
#hostlist is an argument required for the horovodrun command, containing the ip addresses and number of processes of all nodes
#$1: Name of the cloud environment for artifact naming (e. g. openstack will result in openstack:inventory and openstack:hostlist)
#$2: Number of processes per node, supplied from the PROCESS variable defined within gitlab-ci.yml

#!/bin/bash

echo "[master]" >> ../$1:inventory
terraform output -raw master_instance_ip >> ../$1:inventory
echo -en "\n" >> ../$1:inventory
echo -en "\n" >> ../$1:inventory
echo "[workers]" >> ../$1:inventory
terraform output -json worker_instance_ips | jq -r '.[]' >> ../$1:inventory
echo -n "localhost:$2" > ../$1:hostlist
terraform output -json worker_instance_ips | jq -jr --arg processCount $2 '"," + .[] + ":" + $processCount' >> ../$1:hostlist
