helm delete infogrep
helm delete cnpg -n cnpg-system
helm delete elastic-operator -n elastic-system
helm delete milvus-operator -n milvus-operator
helm delete istio-base -n istio-system
helm delete istiod -n istio-system
kubectl delete crds agents.agent.k8s.elastic.co
kubectl delete crds apmservers.apm.k8s.elastic.co
kubectl delete crds authorizationpolicies.security.istio.io
kubectl delete crds backups.postgresql.cnpg.io
kubectl delete crds beats.beat.k8s.elastic.co
kubectl delete crds clusterimagecatalogs.postgresql.cnpg.io
kubectl delete crds clusters.postgresql.cnpg.io
kubectl delete crds databases.postgresql.cnpg.io
kubectl delete crds destinationrules.networking.istio.io
kubectl delete crds elasticmapsservers.maps.k8s.elastic.co
kubectl delete crds elasticsearchautoscalers.autoscaling.k8s.elastic.co
kubectl delete crds elasticsearches.elasticsearch.k8s.elastic.co
kubectl delete crds enterprisesearches.enterprisesearch.k8s.elastic.co
kubectl delete crds envoyfilters.networking.istio.io
kubectl delete crds gateways.networking.istio.io
kubectl delete crds imagecatalogs.postgresql.cnpg.io
kubectl delete crds kibanas.kibana.k8s.elastic.co
kubectl delete crds logstashes.logstash.k8s.elastic.co
kubectl delete crds peerauthentications.security.istio.io
kubectl delete crds poolers.postgresql.cnpg.io
kubectl delete crds proxyconfigs.networking.istio.io
kubectl delete crds publications.postgresql.cnpg.io
kubectl delete crds requestauthentications.security.istio.io
kubectl delete crds scheduledbackups.postgresql.cnpg.io
kubectl delete crds serviceentries.networking.istio.io
kubectl delete crds sidecars.networking.istio.io
kubectl delete crds stackconfigpolicies.stackconfigpolicy.k8s.elastic.co
kubectl delete crds subscriptions.postgresql.cnpg.io
kubectl delete crds telemetries.telemetry.istio.io
kubectl delete crds virtualservices.networking.istio.io
kubectl delete crds wasmplugins.extensions.istio.io
kubectl delete crds workloadentries.networking.istio.io
