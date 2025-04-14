# InfoGrep Deployment

Helm Charts for deploying InfoGrep

## Development with Minikube

### Dependencies

- [Install Docker](https://docker.com)
  - (Important) make sure to give enough CPU & RAM resource, you can adjust this setting in Docker by first turn off the resource saver in the resource settings tab.
  - For Mac users, it is better to use Docker VMM for the Virtual Machine Options, you can adjust this setting in the General settings tab.
- [Install Helm](https://helm.sh/docs/intro/install/).
- [Install Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download).
- [Install Istioctl and add the CLI to PATH](https://istio.io/latest/docs/setup/additional-setup/download-istio-release/).

### Setup Steps

1. Start a single node cluster with `minikube start --cpus max --memory max`, this is recommended to members that does not have too much compute resource available on there machine
   1. For the ones that want to try a multi-node cluster, run `minikube start --cpus 2 --memory 5120 --disk-size 20gb -n 3` to spin up a 3 node cluster, note that you will need at least 15G memory, 6 cpu cores, and 60G storage free to allocate, they won't all necessarily get used.
2. Make sure to install the CSI Driver addon with `minikube addons enable volumesnapshots` and `minikube addons enable csi-hostpath-driver`
3. Make sure to install the nginx ingress addon with `minikube addons enable ingress` and `minikube addons enable ingress-dns`
4. Create the `config.yaml` file from the `config.template.yaml` file with `cp config.template.yaml config.yaml`. Set up the `config.yaml` with appropriate values, reach out to @TyroneHe-0926 for any questions.
   1. `deploymentType` should be `dev`
   2. `Ingress.className` should be `nginx`
5. Run the setup script with `bash scripts/setup.sh`.

### Testing

- Add `127.0.0.1 local.infogrep.ai` to your hosts file, for Mac users it should be `/etc/hosts`.
- Run `minikube tunnel --cleanup` to tunnel all the services out to `127.0.0.1`. You might need to input your password.
- You should now be able to visit local.infogrep.ai, try something like `curl local.infogrep.ai/auth/login` to verify the routing works

## Self Managed Clusters

### Dependencies

- [Install Helm](https://helm.sh/docs/intro/install/).
- [Install Istioctl and add the CLI to PATH](https://istio.io/latest/docs/setup/additional-setup/download-istio-release/).
- [Install Longhorn](https://longhorn.io/docs/1.8.1/deploy/install/install-with-helm/). You might need to configure each node in order to properly setup Longhorn, please see the requirements [here](https://longhorn.io/docs/1.8.1/deploy/install/#installation-requirements)

### Setup Steps

1. We currently support traefikv2, traefikv3, nginx, and istio-ingress-gateway as ingress classes, please make sure the ingress controller is deployed before installing InfoGrep. 
2. Create the `config.yaml` file from the `config.template.yaml` file with `cp config.template.yaml config.yaml`. Set up the `config.yaml` with appropriate values, reach out to @TyroneHe-0926 for any questions.
   1. `deploymentType` should be `local`
   2. change `Ingress.host` to your host for infogrep (e.g. infogrep.mydomain.com)
3. Run the setup script with `bash scripts/setup.sh`.

### Testing

- InfoGrep will be avalible the host configured in config.yaml. Try `curl http://infogrephost/ai/api/docs` to verify the routing works.
