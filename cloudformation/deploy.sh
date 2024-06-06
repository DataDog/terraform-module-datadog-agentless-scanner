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
STACK_SCANNER_CHANNEL=${STACK_SCANNER_CHANNEL:-stable}
STACK_SCANNER_SSH_KEY_PAIR_NAME=${STACK_SCANNER_SSH_KEY_PAIR_NAME:-}
STACK_SCANNER_VPC_ID=${STACK_SCANNER_VPC_ID:-}
STACK_SCANNER_SUBNET_ID=${STACK_SCANNER_SUBNET_ID:-}
STACK_SCANNER_SECURITY_GROUP_ID=${STACK_SCANNER_SECURITY_GROUP_ID:-}
STACK_SCANNER_OFFLINE_MODE_ENABLED=${STACK_SCANNER_OFFLINE_MODE_ENABLED:-false}

printf "validating template %s..." "${STACK_NAME}"
aws cloudformation validate-template --template-body "${STACK_TEMPLATE_BODY}" > /dev/null
printf " ok.\n"

PARAMETER_OVERRIDES=(
  "DatadogAPIKey=${STACK_DATADOG_API_KEY}" \
  "DatadogAPPKey=${STACK_DATADOG_APP_KEY}" \
  "DatadogSite=${STACK_DATADOG_SITE}" \
  "ScannerSSHKeyPairName=${STACK_SCANNER_SSH_KEY_PAIR_NAME}" \
  "ScannerChannel=${STACK_SCANNER_CHANNEL}" \
  "ScannerVPCId=${STACK_SCANNER_VPC_ID}" \
  "ScannerSubnetId=${STACK_SCANNER_SUBNET_ID}" \
  "ScannerSecurityGroupId=${STACK_SCANNER_SECURITY_GROUP_ID}" \
  "ScannerDelegateRoleName=${STACK_NAME}DelegateRole" \
  "ScannerOfflineModeEnabled=${STACK_SCANNER_OFFLINE_MODE_ENABLED}" \
  "AgentlessHostScanning=true" \
  "AgentlessContainerScanning=true" \
  "AgentlessLambdaScanning=true" \
  "AgentlessSensitiveDataScanning=true"
)

printf "deploying stack %s in region %s with parameters:\n" "${STACK_NAME}" "${STACK_AWS_REGION}"
printf "  DatadogAPIKey=%s\n" "***$(echo -n "${STACK_DATADOG_API_KEY}" | tail -c 4)"
printf "  DatadogAPPKey=%s\n" "***$(echo -n "${STACK_DATADOG_APP_KEY}" | tail -c 4)"
for param_override in "${PARAMETER_OVERRIDES[@]}"; do
  if [[ "${param_override}" != "DatadogAPIKey="* ]] && [[ "${param_override}" != "DatadogAPPKey="* ]]; then
    printf "  %s\n" "${param_override}"
  fi
done

aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$STACK_TEMPLATE_FILE" \
  --region "$STACK_AWS_REGION" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "${PARAMETER_OVERRIDES[@]}"

printf "ok.\n"

STACK_ID=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$STACK_AWS_REGION" \
  --query 'Stacks[0].StackId' \
  --output text)

printf "waiting for instance to scale up..."
while true; do
  STACK_INSTANCE_IP=$(aws ec2 describe-instances \
      --filters \
        "Name=tag:aws:cloudformation:stack-id,Values=${STACK_ID}" \
        "Name=instance-state-name,Values=running" \
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
