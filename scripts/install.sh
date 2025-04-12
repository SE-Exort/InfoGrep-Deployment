#!/bin/bash

# check istioctl is installed
if ! command -v istioctl 2>&1 >/dev/null
then
  echo "istioctl is not installed or is not in PATH! Exiting..."
  exit 1
fi

# check if config.yaml exists
if [ ! -f config.yaml ]; then
  echo "config.yaml not found! Exiting..."
  exit 1
fi

INFOGREP_CHART_DIR="./infogrep-charts"

# adding helm repos
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo add elastic https://helm.elastic.co
helm repo add milvus-operator https://zilliztech.github.io/milvus-operator/
helm repo update

# installing istio
helm upgrade --install istio-base istio/base \
  -n istio-system \
  --set defaultRevision=default \
  --create-namespace --wait \
  --version 1.24.2

helm upgrade --install istiod istio/istiod \
  -n istio-system --wait \
  --version 1.24.2

istioctl install -f "${INFOGREP_CHART_DIR}/hack/mesh-config.yaml" --skip-confirmation

# installing cnpg CRD & operator
helm upgrade --install cnpg cnpg/cloudnative-pg \
  -n cnpg-system \
  --create-namespace --wait \
  --version 0.23.2

# installing eck CRD & operator
helm upgrade --install elastic-operator elastic/eck-operator \
  -n elastic-system \
  --create-namespace --wait \
  --version 2.16.1

# installing milvus CRD & operator
helm upgrade --install milvus-operator milvus-operator/milvus-operator \
  -n milvus-operator \
  --create-namespace --wait \
  --version 1.2.1

# install infogrep charts
helm install -f config.yaml infogrep ${INFOGREP_CHART_DIR} --create-namespace

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