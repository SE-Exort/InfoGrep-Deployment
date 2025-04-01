#!/bin/bash

function check_envvar {
    local envvar=$1
    local vartype=$2

    if [ -z "${!envvar}" ]; then
        if [ "$vartype" == "required" ]; then
            echo "Error: $envvar is required but not set. Exiting..."
            exit 1
        else
            export $envvar="EMPTY"
            echo "$envvar optional and not set, default to empty "
        fi
    else
        echo "$envvar is set."
    fi
}

function check_boolean {
    local var_name=$1
    local var_value=${!var_name}
    
    var_value=$(echo "$var_value" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$var_value" == "true" || "$var_value" == "1" || "$var_value" == "yes" || "$var_value" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

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

# check required env var
check_envvar MILVUS_USER_PASSWORD required
check_envvar MILVUS_ROOT_PASSWORD required
check_envvar POSTGRES_ROOT_PASSWORD required
check_envvar DTYPE required

check_envvar OPENAI_KEY optional
check_envvar GHCR_USER optional
check_envvar GHCR_PASSWORD optional
check_envvar GHCR_EMAIL optional
check_envvar CLIENT_ID optional
check_envvar CLIENT_SECRET optional
check_envvar DOMAIN optional
check_envvar APP_SECRET_KEY optional
check_envvar REDIRECT_URI optional
check_envvar FRONTEND_LOGIN_URI optional

# check istioctl is installed
if ! command -v istioctl 2>&1 >/dev/null
then
    echo "istioctl is not installed or is not in PATH! Exiting..."
    exit 1
fi

INFOGREP_CHART_DIR="./charts"
ECK_OPERATOR_CHART_DIR="./eck-operator-charts"
MILVUS_OPERATOR_CHART_DIR="./milvus-operator-charts"
CNPG_OPERATOR_CHART_DIR="./cloudnative-pg-charts"

# adding helm repos
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# installing istio
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace --wait --version 1.24.2
helm install istiod istio/istiod -n istio-system --wait --version 1.24.2
kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/mtls.yaml"

# installing Jaegar
if check_boolean ENABLE_JAEGER; then
    echo "Installing Jaeger..."
    kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/jaegar.yaml"
    istioctl install -f "${INFOGREP_CHART_DIR}/monitoring/tracing.yaml" --skip-confirmation
    kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/mesh-default-tracing.yaml"
else
    echo "Skipping Jaeger installation"
fi

# installing Grafana & Prometheus
if check_boolean ENABLE_INFOGREP_METRICS; then
    echo "Installing Prometheus and Grafana..."
    kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/prometheus.yaml"
    kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/grafana.yaml"
else
    echo "Skipping Prometheus and Grafana installation"
fi

# installing kiali
if check_boolean ENABLE_KIALI; then
    echo "Installing Kiali..."
    kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/kiali.yaml"
else
    echo "Skipping Kiali installation (ENABLE_KIALI not enabled)"
fi

# installing the ELK operator
helm install elastic-operator $ECK_OPERATOR_CHART_DIR -n elastic-system --create-namespace --wait \
    --values="${ECK_OPERATOR_CHART_DIR}/profile-istio.yaml" \

# installing the Milvus operator
helm install milvus-operator $MILVUS_OPERATOR_CHART_DIR -n milvus-operator --create-namespace --wait

# installing the CNPG operator
helm install cnpg $CNPG_OPERATOR_CHART_DIR -n cnpg-system --create-namespace --wait

# install charts
helm install infogrep $INFOGREP_CHART_DIR \
    --set deploymentType=$DTYPE \
    --set KeyConfig.openaiKey=$OPENAI_KEY \
    --set AuthService.env.CLIENT_ID=$CLIENT_ID \
    --set AuthService.env.CLIENT_SECRET=$CLIENT_SECRET \
    --set AuthService.env.DOMAIN=$DOMAIN \
    --set AuthService.env.APP_SECRET_KEY=$APP_SECRET_KEY \
    --set MilvusConfig.env.password=$MILVUS_USER_PASSWORD \
    --set MilvusConfig.env.rootPassword=$MILVUS_ROOT_PASSWORD \
    --set AuthService.env.REDIRECT_URI=$REDIRECT_URI \
    --set AuthService.env.FRONTEND_LOGIN_URI=$FRONTEND_LOGIN_URI \
    --set InfogrepPostgres.env.password=$POSTGRES_ROOT_PASSWORD

# create ghcr image pull secret
kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=$GHCR_USER --docker-password=$GHCR_PASSWORD --docker-email=$GHCR_EMAIL -n infogrep

# issue cnpg client cert
curl -sSfL \
  https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | \
  sh -s -- -b ./

./kubectl-cnpg certificate infogrep-cnpg-client-cert \
  --cnpg-cluster infogrep-postgres \
  --cnpg-user postgres \
  -n infogrep

rm ./kubectl-cnpg

echo -e "\033[1;33m \t ***** InfoGrep Successfully Deployed! ***** \t"

cat << EOF
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@++=========*%@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#+-:=@%%@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@#===-------*@@@+-#@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@#=====#@@@@@@@@@@%@@=#@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@%@@+===+@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@%@@===*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@%@@===%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@===%@@@@*++++++@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@===%@@@@+=@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@===%@@@@++@+=====---+@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@===%@@@@+-*###@@@@@=--%@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@===%@@@@%%%%@@@@@#@#--+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@===#@@@@%@@@@@@@@#@#--+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@#==-#@@@@@@@@@@@@#@#--+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@%=---*@@@@@@@@@@#@#--+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@*=---::::---*#@#--+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=--+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@*==------------+@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EOF