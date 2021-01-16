#!/usr/bin/env bash
DEBUG=${DEBUG:-}
if [ ! -z "${DEBUG}" ]; then
    set -x
fi

set -euo pipefail
mkdir -p tmp

# Delete the stack and the key pair.
aws cloudformation delete-stack --stack-name ec2-k3d
aws ec2 delete-key-pair --key-name MyKeyPair
rm -rf tmp

# Success
echo -e "\nSuccessufly removed the EC2 stack and the key pair 🎉"
