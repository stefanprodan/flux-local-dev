# flux-local-dev

[Flux](https://fluxcd.io) local dev environment with Docker and Kubernetes KIND.

## Who is this for?

- **Flux users** who want to test Flux configs locally, without having to push changes to a Git repository. 
  Config changes are pushed to a local registry and synced on the cluster by Flux automatically.
- **Flux contributors** who want to test their changes to Flux controllers locally,
  without having to push the container images to an external registry.
- **Flux maintainers** who want to test Flux prereleases on various Kubernetes versions and configurations.

## How it works?

This project spins up a Docker Registry container named `kind-registry` and a Kubernetes Kind cluster
named `flux` under the same Docker network. Then it installs Flux and configures it to upgrade itself
from the latest OCI artifact published at `ghcr.io/fluxcd/flux-manifests`.

| Component             | Role                            | Host                        |
|-----------------------|---------------------------------|-----------------------------|
| Kubernetes KIND       | Local cluster                   | Binds to port 80 and 443    |
| Docker Registry       | Local registry                  | Binds to port 5050          |
| Flux                  | Cluster reconciler              | -                           |
| ingress-nginx         | Ingress for `*.flux.local`      | -                           |
| cert-manager          | Self-signed ingress certs       | -                           |
| metrics-server        | Container resource metrics      | -                           |
| kube-prometheus-stack | Prometheus Operator and Grafana | Binds to grafana.flux.local |
| weave-gitops          | Flux UI                         | Binds to ui.flux.local      |
| podinfo               | Demo app                        | Binds to podinfo.flux.local |

The Docker registry is exposed on the local machine on `localhost:5050` and inside the cluster
on `kind-registry:5000`. The registry servers two purposes:
- hosts container images e.g. `docker push localhost:5050/podinfo:test1`
- hosts OCI artifacts e.g. `flux push artifact oci://localhost:5050/podinfo-manifests:test1`

To facilitate ingress access to the Flux UI and any other
application running inside the cluster, the Kubernetes Kind container
binds to port `80` and `443` on localhost.
Ingress is handled by Kubernetes ingress-nginx and self-signed TLS certs
are provided by cert-manager.

To monitor how the deployed applications perform on the cluster,
the kube-prometheus-stack and metrics-server Helm charts are installed at
bootstrap along with the Flux Grafana dashboards.

To monitor and debug Flux using a Web UI, the Weave GitOps Helm chart is
installed at bootstrap.


## How to get started?

Install Kubernetes kind, kubectl, flux and other CLI tools with Homebrew:

```shell
make tools
```

Create the local cluster and registry:

```shell
make up
```

Before running `up` make sure the following ports are free on your local machine: `5050`, `80` and `443`.

Add the following domains to `/etc/hosts`:

```txt
127.0.0.1 podinfo.flux.local
127.0.0.1 grafana.flux.local
127.0.0.1 ui.flux.local
```

Verify that the NGINX ingress self-signed TLS works:

```shell
make check
```

Access the Flux UI and Grafana using the username `admin` and password `flux`:

- [http://ui.flux.local/applications](http://ui.flux.local/applications)
- [http://grafana.flux.local/d/flux-control-plane](http://grafana.flux.local/d/flux-control-plane/flux-control-plane?orgId=1&refresh=10s)
- [http://grafana.flux.local/d/flux-cluster](http://grafana.flux.local/d/flux-cluster/flux-cluster-stats?orgId=1&refresh=10s)

Access the demo application on [http://podinfo.flux.local](http://ui.flux.local/).

Teardown the whole environment with:

```shell
make down
```
