# InfoGrep Deployment

Helm Charts for deploying InfoGrep

## Steps (Local Minikube)

### Dependencies

- [Install Docker](https://docker.com)
  - (Important) make sure to give enough CPU & RAM resource, you can adjust this setting in Docker by first turn off the resource saver in the resource settings tab.
  - For Mac users, it is better to use Docker VMM for the Virtual Machine Options, you can adjust this setting in the General settings tab.
- [Install Helm](https://helm.sh/docs/intro/install/).
- [Install Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download).
- [Install Istioctl and add the CLI to PATH](https://istio.io/latest/docs/setup/additional-setup/download-istio-release/).
- [Install Ollama](https://ollama.com/download)

### Setup Steps

1. Start a single node cluster with `minikube start --cpus max --memory max`, this is recommended to members that does not have too much compute resource available on there machine
   1. For the ones that want to try a multi-node cluster, run `minikube start --cpus 2 --memory 5120 --disk-size 20gb -n 3` to spin up a 3 node cluster, note that you will need at least 15G memory, 6 cpu cores, and 60G storage free to allocate, they won't all necessarily get used.
2. `ollama serve` to start ollama.
3. Create the `.env` file from the `.env.template` file with `cp .env.template .env`. Fill out the mandatory env vars with an appropriate value. If you are not sure what to put in, reach out to @TyroneHe-0926.
4. Run the setup script with `bash setup.sh`.

### Testing

- Run `minikube tunnel --cleanup` to tunnel all the services out to `127.0.0.1`. You might need to input your password.
- For a full list of service, run `kubectl get svc -n infogrep`, any service with an external IP will be accessible.
- For example, to access the auth service, simply `curl http://127.0.0.1:4000`.

### Integrations

- For observability dashboards, run:
  - `istioctl dashboard grafana` for Grafana,
  - `istioctl dashboard jaeger` for distributed tracing,
  - `istioctl dashboard kiali` for traffic graphs.
- For logging, access the kibana dashboard at `https://127.0.0.1:5601`
  - the user is just the default user `elastic`
  - you can obtain the password with the following command `kubectl get secret infogrep-elasticsearch-logs-es-elastic-user -n infogrep -o go-template='{{.data.elastic | base64decode}}'`.
