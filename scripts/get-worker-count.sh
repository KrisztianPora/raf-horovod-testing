#Handles the customization of the number of worker nodes during manual executions. The script was necessary because Terraform reads this parameter from descriptor files.
#The script starts by reading the worker count from the descriptor file. This will be OLDWORKER.
#If the pipeline was started manually (web), the value specified by the user, WORKER will be put both into the files and variables going forward.
#If its not a manual run, the value read from the files, OLDWORKER is put into a variable going forward.
#The argument $1 is the name of the variable the script should put the value in. (OPENSTACK_WORKER or AWS_WORKER)
#Separated variables per cloud environments were necessary since it is not guaranteed that the worker count in their descriptor files are equal.

#!/bin/bash

OLDWORKER=$(awk -F= '/^.*count/{gsub(/ /,"",$2);print $2}' resources.auto.tfvars)

if [ $CI_PIPELINE_SOURCE == "web" ]; then
    echo "This is a web run, the worker count is read from variable: $WORKER"
    sed -i "s%count = $OLDWORKER%count = $WORKER%g" resources.auto.tfvars
    echo "Value in terraform file replaced from $OLDWORKER to: $(awk -F= '/^.*count/{gsub(/ /,"",$2);print $2}' resources.auto.tfvars) "
    eval $1=$WORKER
    echo "Value carried forward as variable "$1" = $WORKER"
else
    eval $1=$OLDWORKER
    echo "This is not a web run, the worker value is read from file: $OLDWORKER"
    echo "Value carried forward as variable "$1" = $OLDWORKER"
fi

