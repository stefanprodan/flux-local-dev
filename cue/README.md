# Podinfo CUE module

This directory contains a [CUE](https://cuelang.org/docs/) module and tooling
for generating [podinfo](https://github.com/stefanprodan/podinfo)'s Kubernetes resources.

The module contains a `podinfo.#App` definition which takes `podinfo.#AppSpec` as input.

## Prerequisites

Install CUE with:

```shell
brew install cue
```

## Configuration

Configure the application in `main.cue`:

```cue
app: podinfo.#App & {
	spec: {
		meta: {
			name:      "podinfo"
			namespace: appsNamespace.spec.name
		}
		image: tag: "6.2.0"
		resources: requests: {
			cpu:    "100m"
			memory: "16Mi"
		}
		hpa: {
			enabled:     true
			maxReplicas: 3
		}
		ingress: {
			enabled:   true
			className: "nginx"
			host:      "podinfo.flux.local"
			tls:       true
			annotations: {
				"nginx.ingress.kubernetes.io/ssl-redirect":       "false"
				"nginx.ingress.kubernetes.io/force-ssl-redirect": "false"
				"cert-manager.io/cluster-issuer":                 "self-signed"
			}
		}
		serviceMonitor: enabled: true
	}
}
```

## Generate the manifests

```shell
cue gen
```
