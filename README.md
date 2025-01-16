# InfoGrep Deployment

Helm Charts for deploying InfoGrep

## Steps (Local Minikube)

1. [Install Docker](https://docker.com), [Install Helm](https://helm.sh/docs/intro/install/), [Install Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download), [Install Istioctl and add the CLI to PATH](https://istio.io/latest/docs/setup/additional-setup/download-istio-release/)
2. For Mac users on Apple Silicon Chips, make sure rosetta is installed, run a `sudo softwareupdate --install-rosetta` if not, Select Docker VMM for Virtual Machine Options in Docker Desktop under Settings -> General.
3. `minikube start` to start your k8s cluster.
4. get your OpenAI api key and set it with `export OPENAI_KEY=<Your Key>`
5. (optional) get a SerpAPI key and set it with `export SERPAPI_KEY=<Your Key>`. If you don't want to, just remove the `--set KeyConfig.serpapiKey` part from the helm install command.
6. set your GHCR env variables with `export GHCR_USER=<Your-GitHub-Username>`, `export GHCR_PASSWORD=<Your-GitHub-Token>`, `export GHCR_EMAIL=<Your-GitHub-Email>`.
7. `cd charts` and run `bash setup.sh` to install the k8s charts, the cluster should be ready in ~10 min.

## Deprecated

### Old Steps

1. [Install Docker](https://docker.com) if you haven't, and make sure it's running the latest version
2. [Install Helm](https://helm.sh/docs/intro/install/) if you haven't.
3. For Mac users on Apple Silicon Chips, run a `sudo softwareupdate --install-rosetta`
4. Go to the [minikube installer page](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) and download minikube.
5. `minikube start` to start your k8s cluster.
6. (optional) `minikube addons enable dashboard` for a nice k8s GUI.
7. get your OpenAI api key and set it with `export OPENAI_KEY=<Your Key>`
8. (optional) get a SerpAPI key and set it with `export SERPAPI_KEY=<Your Key>`. If you don't want to, just remove the `--set KeyConfig.serpapiKey` part from the helm install command.
9. set your GHCR env variables with `export GHCR_USER=<Your-GitHub-Username>`, `export GHCR_PASSWORD=<Your-GitHub-Token>`, `export GHCR_EMAIL=<Your-GitHub-Email>`.
10. `cd charts` and `helm upgrade -i --set KeyConfig.openaiKey=$OPENAI_KEY --set KeyConfig.serpapiKey=$SERPAPI_KEY infogrep . && kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=$GHCR_USER --docker-password=$GHCR_PASSWORD --docker-email=$GHCR_EMAIL -n infogrep` to install the kubernetes manifests and create the image pull secret.
11. run `minikube service <Servie you want to test> -n infogrep` this will tunnel out the service running inside the cluster to your localhost, outputing a localhost port that you can call. Keep this command running and you can now call the endpoint with the outputted port.

### Ingress Settings

- `minikube addons enable ingress` and `minikube addons enable ingress-dns` for the nginx controller.
- `minikube addons enable ingress` and `minikube addons enable ingress-dns` for the nginx controller.
- verify the ingress is working with `kubectl get ingress -n infogrep` and you should see an nginx ingress show up with host and address.
- `minikube tunnel` if using Mac, probably in a `screen` or just keep that window open.
- test endpoint, for example, testing the AI Service swagger endpoint with `curl --resolve "local.infogrep.ai:80:127.0.0.1" -i http://local.infogrep.ai/docs`
