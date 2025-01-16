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

# check required env var
check_envvar OPENAI_KEY required
check_envvar GHCR_USER required
check_envvar GHCR_PASSWORD required
check_envvar GHCR_EMAIL required
check_envvar SERPAPI_KEY optional

# check istioctl is installed
if ! command -v istioctl 2>&1 >/dev/null
then
    echo "istioctl is not installed or is not in PATH! Exiting..."
    exit 1
fi

# adding istio helm repo
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# installing istio
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm install istiod istio/istiod -n istio-system --wait

# installing Jaegar
kubectl apply -f "./monitoring/jaegar.yaml"
istioctl install -f "./monitoring/tracing.yaml" --skip-confirmation
kubectl apply -f "./monitoring/mesh-default-tracing.yaml"

# installing Grafana & Prometheus
kubectl apply -f "./monitoring/prometheus.yaml"
kubectl apply -f "./monitoring/grafana.yaml"

# installing kiali
kubectl apply -f "./monitoring/kiali.yaml"

# install charts
helm upgrade -i --set KeyConfig.openaiKey=$OPENAI_KEY --set KeyConfig.serpapiKey=$SERPAPI_KEY infogrep .

# create ghcr image pull secret
kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=$GHCR_USER --docker-password=$GHCR_PASSWORD --docker-email=$GHCR_EMAIL -n infogrep