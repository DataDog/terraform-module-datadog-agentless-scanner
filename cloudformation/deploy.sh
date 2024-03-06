#!/bin/bash

set -e
set -u
set -o pipefail

STACK_NAME_SUFFIX="${STACK_NAME_SUFFIX:-}"
STACK_NAME="DatadogAgentlessScanner${STACK_NAME_SUFFIX}"
STACK_AWS_REGION="us-east-1"
STACK_DATADOG_SITE="${STACK_DATADOG_SITE:-datad0g.com}"
STACK_TEMPLATE_FILE="$(dirname "$0")/main.yaml"
STACK_TEMPLATE_BODY="$(cat "${STACK_TEMPLATE_FILE}")"
STACK_SCANNER_SSH_KEY_PAIR_NAME=${STACK_SCANNER_SSH_KEY_PAIR_NAME:-}
STACK_SCANNER_VPC_ID=${STACK_SCANNER_VPC_ID:-}
STACK_SCANNER_SUBNET_ID=${STACK_SCANNER_SUBNET_ID:-}
STACK_SCANNER_SECURITY_GROUP_ID=${STACK_SCANNER_SECURITY_GROUP_ID:-}
STACK_SCANNER_OFFLINE_MODE_ENABLED=${STACK_SCANNER_OFFLINE_MODE_ENABLED:-false}

printf "validating template %s..." "${STACK_NAME}"
aws cloudformation validate-template --template-body "${STACK_TEMPLATE_BODY}" > /dev/null
printf " ok.\n"

printf "deploying stack %s..." "${STACK_NAME}"
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$STACK_TEMPLATE_FILE" \
  --region "$STACK_AWS_REGION" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    "DatadogAPIKey=${STACK_DATADOG_API_KEY}" \
    "DatadogSite=${STACK_DATADOG_SITE}" \
    "ScannerSSHKeyPairName=${STACK_SCANNER_SSH_KEY_PAIR_NAME}" \
    "ScannerVPCId=${STACK_SCANNER_VPC_ID}" \
    "ScannerSubnetId=${STACK_SCANNER_SUBNET_ID}" \
    "ScannerSecurityGroupId=${STACK_SCANNER_SECURITY_GROUP_ID}" \
    "ScannerDelegateRoleName=${STACK_NAME}DelegateRole" \
    "ScannerOfflineModeEnabled=${STACK_SCANNER_OFFLINE_MODE_ENABLED}"
printf "ok.\n"

STACK_ID=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$STACK_AWS_REGION" \
  --query 'Stacks[0].StackId' \
  --output text)

printf "waiting for instance to scale up..."
while true; do
  STACK_INSTANCE_IP=$(aws ec2 describe-instances \
      --filters "Name=tag:aws:cloudformation:stack-id,Values=${STACK_ID}" \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text)
  if [ "$STACK_INSTANCE_IP" = "None" ]; then
    sleep 10
    printf "."
  else
    echo "stack creation successful"
    echo "export STACK_INSTANCE_IP=\"${STACK_INSTANCE_IP}\""
    echo "ssh -i ~/.ssh/sidescanner ubuntu@\$STACK_INSTANCE_IP"
    exit 0
  fi
done
