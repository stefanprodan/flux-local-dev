package podinfo

import (
	netv1 "k8s.io/api/networking/v1"
)

#ingressConfig: {
	enabled: *false | bool
	annotations?: {[ string]: string}
	className?: string
	tls:        *false | bool
	host:       string
}

#Ingress: netv1.#Ingress & {
	_spec:      #AppSpec
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata:   _spec.meta
	if _spec.ingress.annotations != _|_ {
		metadata: annotations: _spec.ingress.annotations
	}
	spec: netv1.#IngressSpec & {
		rules: [{
			host: _spec.ingress.host
			http: {
				paths: [{
					pathType: "Prefix"
					path:     "/"
					backend: service: {
						name: _spec.meta.name
						port: name: "http"
					}
				}]
			}
		}]
		if _spec.ingress.tls {
			tls: [{
				hosts: [_spec.ingress.host]
				secretName: "\(_spec.meta.name)-cert"
			}]
		}
		if _spec.ingress.className != _|_ {
			ingressClassName: _spec.ingress.className
		}
	}
}
