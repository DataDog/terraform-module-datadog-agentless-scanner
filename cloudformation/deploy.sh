#!/bin/bash

set -e
set -u
set -o pipefail

STACK_NAME_SUFFIX="${STACK_NAME_SUFFIX:-}"
STACK_NAME="DatadogAgentlessScanner${STACK_NAME_SUFFIX}"
STACK_AWS_REGION="us-east-1"
STACK_DATADOG_API_KEY="${STACK_DATADOG_API_KEY}"
STACK_DATADOG_SITE="${STACK_DATADOG_SITE:-datad0g.com}"
STACK_TEMPLATE_FILE="$(dirname "$0")/main.yaml"
STACK_TEMPLATE_BODY="$(cat "${STACK_TEMPLATE_FILE}")"

printf "validating template %s..." "${STACK_NAME}"
aws cloudformation validate-template --template-body "${STACK_TEMPLATE_BODY}"
printf " ok.\n"

printf "deploying stack %s...\n" "${STACK_NAME}"
STACK_ARN=$(aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$STACK_TEMPLATE_FILE" \
  --region "$STACK_AWS_REGION" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    "DatadogAPIKey=${STACK_DATADOG_API_KEY}" \
    "DatadogSite=${STACK_DATADOG_SITE}" \
    "ScannerDelegateRoleName=${STACK_NAME}DelegateRole" \
  --query 'StackId' \
  --output text)
