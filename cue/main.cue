package main

import (
	ns "github.com/stefanprodan/flux-local-dev/cue/namespace"
	podinfo "github.com/stefanprodan/flux-local-dev/cue/podinfo"
)

appsNamespace: ns.#AppNamespace & {
	spec: {
		name: "cue-apps"
		role: "namespace-admin"
	}
}

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
			host:      "cue-podinfo.flux.local"
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

objects: [appsNamespace, app]
