#!/bin/bash

function check_envvar {
    local param1=$1
    local param2=$2

    if [ -z "${!param1}" ]; then
        if [ "$param2" == "required" ]; then
            echo "Error: $param1 is required but not set. Exiting..."
            exit 1
        else
            export $param1="EMPTY"
            echo "$param1 optional and not set, default to empty "
        fi
    else
        echo "$param1 is set."
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
check_envvar OPENAI_KEY required
check_envvar GHCR_USER required
check_envvar GHCR_PASSWORD required
check_envvar GHCR_EMAIL required
check_envvar AUTH_MODE required
check_envvar SERPAPI_KEY optional
check_envvar CLIENT_ID optional

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
kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/jaegar.yaml"
istioctl install -f "${INFOGREP_CHART_DIR}/monitoring/tracing.yaml" --skip-confirmation
kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/mesh-default-tracing.yaml"

# installing Grafana & Prometheus
# kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/prometheus.yaml"
# kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/grafana.yaml"

# installing kiali
kubectl apply -f "${INFOGREP_CHART_DIR}/monitoring/kiali.yaml"

# installing the ELK operator
helm install elastic-operator $ECK_OPERATOR_CHART_DIR -n elastic-system --create-namespace --wait \
    --values="${ECK_OPERATOR_CHART_DIR}/profile-istio.yaml" \

# installing the Milvus operator
helm install milvus-operator $MILVUS_OPERATOR_CHART_DIR -n milvus-operator --create-namespace --wait

# installing the CNPG operator
helm install cnpg $CNPG_OPERATOR_CHART_DIR -n cnpg-system --create-namespace --wait

# install charts
helm install infogrep $INFOGREP_CHART_DIR \
    --set KeyConfig.openaiKey=$OPENAI_KEY \
    --set KeyConfig.serpapiKey=$SERPAPI_KEY \
    --set AuthService.env.CLIENT_ID=$CLIENT_ID \
    --set AuthService.env.CLIENT_SECRET=$CLIENT_SECRET \
    --set AuthService.env.DOMAIN=$DOMAIN \
    --set AuthService.env.APP_SECRET_KEY=$APP_SECRET_KEY \
    --set AuthService.env.AUTH_MODE=$AUTH_MODE \
    --set MilvusConfig.env.password=infogrep123 \
    --set MilvusConfig.env.rootPassword=rootinfogrep123

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

if nc -z localhost 11434 2>/dev/null; then
    echo -e "Ollama running on localhost"
else
    echo -e "\033[0;31m \t !!!!! Looks like Ollama is not running on your machine, please ensure that it is running. \t !!!!!"
fi

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