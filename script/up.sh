#!/usr/bin/env bash
DEBUG=${DEBUG:-}
if [ ! -z "${DEBUG}" ]; then
    set -x
fi

set -euo pipefail
mkdir -p tmp

# Grab EC2 type with a default of "t2.small".
EC2_TYPE=${1-small}

# Create a new key pair.
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > tmp/key.pem
chmod 400 tmp/key.pem

# Create the stack
sed -i "0,/small/s//${EC2_TYPE}/" parameters.json
aws cloudformation deploy --template-file template.yaml --stack-name ec2-k3d --parameter-overrides file://parameters.json
PUBLIC_DNS="$(aws cloudformation describe-stacks --stack-name ec2-k3d --query "Stacks[0].Outputs[?OutputKey=='PublicDNS'].OutputValue" --output text)"
sed -i "0,/${EC2_TYPE}/s//small/" parameters.json

# Success
echo -e "\nSuccessufly created the EC2 stack and tke key pair 🎉"
echo -e "\nType the following command to login to EC2:"
echo -e "ssh -i tmp/key.pem ec2-user@${PUBLIC_DNS}"