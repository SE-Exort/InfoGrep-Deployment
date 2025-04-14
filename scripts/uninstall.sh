helm delete infogrep --wait
echo "infogrep uninstalled"

helm delete cnpg -n cnpg-system --wait
kubectl delete ns cnpg-system
echo "cnpg operator uninstalled"

helm delete elastic-operator -n elastic-system --wait
kubectl delete ns elastic-system
echo "eck operator uninstalled"

helm delete milvus-operator -n milvus-operator --wait
kubectl delete ns milvus-operator
echo "milvus operator uninstalled"

istioctl uninstall -y --purge
kubectl delete ns istio-system
echo "istio uninstalled"

kubectl get crd -oname | grep --color=never 'cnpg.io' | xargs kubectl delete
kubectl get crd -oname | grep --color=never 'elastic.co' | xargs kubectl delete
kubectl get crd -oname | grep --color=never 'milvus.io' | xargs kubectl delete
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
echo "cleaned up CRDs"