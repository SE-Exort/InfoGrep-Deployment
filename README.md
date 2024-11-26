# InfoGrep Deployment

Helm Charts for deploying InfoGrep

## Steps (Local Minikube)

1. Go to the [minikube installer page](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) and download minikube.
2. `minikube start` to start your k8s cluster.
3. `minikube addons enable ingress` and `minikube addons enable ingress-dns` for the nginx controller.
4. (optional) `minikube addons enable dashboard` for a nice k8s GUI.
5. `helm upgrade -i infogrep` to install the kubernetes manifests.
6. `kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=<Your-GitHub-Username> --docker-password=<Your-GitHub-Token> --docker-email=<Your-GitHub-Email> --namespace infogrep` to create the image pull secret.
7. verify the ingress is working with `kubectl get ingress -n infogrep` and you should see an nginx ingress show up with host and address. 
8. `minikube tunnel` if using Mac, probably in a `screen` or just keep that window open.
9. test endpoint, for example, testing the AI Service swagger endpoint with `curl --resolve "local.infogrep.ai:80:127.0.0.1" -i http://local.infogrep.ai/docs`
