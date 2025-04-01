helm delete infogrep
helm delete cnpg -n cnpg-system
helm delete elastic-operator -n elastic-system
helm delete milvus-operator -n milvus-operator
helm delete istio-base -n istio-system
helm delete istiod -n istio-system
kubectl delete ns cnpg-system
kubectl delete ns elastic-system
kubectl delete ns milvus-operator
kubectl delete ns istio-system
