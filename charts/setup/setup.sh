#!/bin/bash

function check_envvar {
    local param1=$1
    local param2=$2

    if [ -z "${!param1}" ]; then
        if [ "$param2" == "required" ]; then
            echo "Error: $param1 is required but not set."
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

# create prereq namespace
kubectl apply -f "./setup/namespace.yaml"

# install istio
kubectl apply -f "./setup/istio/istio-base.yaml"
kubectl apply -f "./setup/istio/istiod.yaml"
kubectl apply -f "./setup/istio/istio-ingress-gateway.yaml"

# install istio addons
kubectl apply -f "./setup/kiali/kiali-base.yaml"
kubectl apply -f "./setup/kiali/kiali.yaml"
kubectl apply -Rf "./setup/monitoring"

# install charts
helm upgrade -i --set KeyConfig.openaiKey=$OPENAI_KEY --set KeyConfig.serpapiKey=$SERPAPI_KEY infogrep .

# create ghcr image pull secret
# create ghcr k8s secret
kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=$GHCR_USER --docker-password=$GHCR_PASSWORD --docker-email=$GHCR_EMAIL -n infogrep