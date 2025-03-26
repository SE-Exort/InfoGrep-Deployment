#!/bin/bash
ENV_FILE=".env"

# Check if the .env file exists
if [[ ! -f "$ENV_FILE" ]]; then
  echo "The env file $ENV_FILE does not exist, please create it with the appropriate value from the .env.template"
  exit 1
fi

# Source the .env file to export the variables
set -a # Automatically export all variables
source "$ENV_FILE"
set +a

echo "Environment variables loaded from $ENV_FILE."

INFOGREP_CHART_DIR="./charts"

helm upgrade -i infogrep $INFOGREP_CHART_DIR \
    --set KeyConfig.openaiKey=$OPENAI_KEY \
    --set AuthService.env.CLIENT_ID=$CLIENT_ID \
    --set AuthService.env.CLIENT_SECRET=$CLIENT_SECRET \
    --set AuthService.env.DOMAIN=$DOMAIN \
    --set AuthService.env.APP_SECRET_KEY=$APP_SECRET_KEY \
    --set AuthService.env.REDIRECT_URI=$REDIRECT_URI \
    --set AuthService.env.FRONTEND_LOGIN_URI=$FRONTEND_LOGIN_URI \
    --set MilvusConfig.env.password=$MILVUS_USER_PASSWORD \
    --set MilvusConfig.env.rootPassword=$MILVUS_ROOT_PASSWORD \
    --set InfogrepPostgres.env.password=$POSTGRES_ROOT_PASSWORD

kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=$GHCR_USER --docker-password=$GHCR_PASSWORD --docker-email=$GHCR_EMAIL -n infogrep
