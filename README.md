# InfoGrep Deployment

Helm Charts for deploying InfoGrep

## Steps (Local Minikube)

1. [Install Docker](https://docker.com) if you haven't, and make sure it's running the latest version
2. [Install Helm](https://helm.sh/docs/intro/install/) if you haven't.
3. For Mac users on Apple Silicon Chips, run a `sudo softwareupdate --install-rosetta`
4. Go to the [minikube installer page](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) and download minikube.
5. `minikube start` to start your k8s cluster.
6. `minikube addons enable ingress` and `minikube addons enable ingress-dns` for the nginx controller.
7. (optional) `minikube addons enable dashboard` for a nice k8s GUI.
8. set your GHCR env variables with `export GHCR_USER=<Your-GitHub-Username>`, `export GHCR_PASSWORD=<Your-GitHub-Token>`, `export GHCR_EMAIL=<Your-GitHub-Email>`.
9. `cd charts` and `helm upgrade -i --set KeyConfig.openaiKey=$OPENAI_KEY --set KeyConfig.serpapiKey=$SERPAPI_KEY infogrep . && kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=$GHCR_USER --docker-password=$GHCR_PASSWORD --docker-email=$GHCR_EMAIL -n infogrep` to install the kubernetes manifests and create the image pull secret.
10. verify the ingress is working with `kubectl get ingress -n infogrep` and you should see an nginx ingress show up with host and address.
11. `minikube tunnel` if using Mac, probably in a `screen` or just keep that window open.
12. test endpoint, for example, testing the AI Service swagger endpoint with `curl --resolve "local.infogrep.ai:80:127.0.0.1" -i http://local.infogrep.ai/docs`
