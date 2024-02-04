#!/usr/bin/bash
PROFILE=${1:-"prod"}
REGION=${2:-"us-east-1"}


aws sso login --profile $PROFILE
aws codeartifact login --tool pip --region $REGION --domain datavant --domain-owner "$AWS_PROFILE_ID" --repository eng --profile $PROFILE
aws codeartifact login --tool npm --region $REGION --domain datavant --domain-owner "$AWS_PROFILE_ID" --repository eng --profile $PROFILE
aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $AWS_PROFILE_ID.dkr.ecr.$REGION.amazonaws.com
