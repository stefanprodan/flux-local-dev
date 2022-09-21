# flux-local-dev

[Flux](https://fluxcd.io) local dev environment with Docker and Kubernetes KIND.

## Bootstrap

Install Kubernetes kind, kubectl, FLux CLI and other tools with Homebrew:

```shell
make tools
```

Create the local cluster and registry, install Flux and the cluster addons:

```shell
make up
```

Before running `up` make sure the following ports are free on your local machine: `5050`, `80` and `443`.

When the command finishes the following components are installed on your local machine:

| Component             | Role                            | Host                        |
|-----------------------|---------------------------------|-----------------------------|
| Kubernetes KIND       | Local cluster                   | Binds to port 80 and 443    |
| Docker Registry       | Local registry                  | Binds to port 5050          |
| ingress-nginx         | Ingress for `*.flux.local`      | Binds to port 80 and 443    |
| cert-manager          | Self-signed ingress certs       | -                           |
| metrics-server        | Container resource metrics      | -                           |
| kube-prometheus-stack | Prometheus Operator and Grafana | Binds to grafana.flux.local |
| weave-gitops          | Flux UI                         | Binds to ui.flux.local      |
| podinfo               | Demo app                        | Binds to podinfo.flux.local |

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

