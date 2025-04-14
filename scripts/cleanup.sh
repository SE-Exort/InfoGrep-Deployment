helm delete infogrep --wait
helm delete cnpg -n cnpg-system --wait
helm delete elastic-operator -n elastic-system --wait
helm delete milvus-operator -n milvus-operator --wait
helm delete istio-base -n istio-system --wait
helm delete istiod -n istio-system
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
kubectl get crd -oname | grep --color=never 'cnpg.io' | xargs kubectl delete
kubectl get crd -oname | grep --color=never 'elastic.co' | xargs kubectl delete
kubectl get crd -oname | grep --color=never 'milvus.io' | xargs kubectl delete