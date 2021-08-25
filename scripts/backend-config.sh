#Sets environment variables required for Terraform Remote Backend, where the state file is stored.
#$1: HTTP address of remote state store
#$2: Name of the state file
#$3: GitLab access token

#!/bin/bash

export TF_ADDRESS=$1$2/
export TF_HTTP_ADDRESS=$TF_ADDRESS
export TF_HTTP_LOCK_ADDRESS=$TF_ADDRESS/lock
export TF_HTTP_LOCK_METHOD=POST
export TF_HTTP_UNLOCK_ADDRESS=$TF_ADDRESS/lock
export TF_HTTP_UNLOCK_METHOD=DELETE
export TF_HTTP_USERNAME=root
export TF_HTTP_PASSWORD=$3
export TF_HTTP_RETRY_WAIT_MIN=5
