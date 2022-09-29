package podinfo

import (
	corev1 "k8s.io/api/core/v1"
)

#serviceConfig: {
	type:         *"ClusterIP" | string
	externalPort: *9898 | int
	httpPort:     *9898 | int
	metricsPort:  *9797 | int
	grpcPort:     *9999 | int
}

#Service: corev1.#Service & {
	_spec:      #AppSpec
	apiVersion: "v1"
	kind:       "Service"
	metadata:   _spec.meta
	spec:       corev1.#ServiceSpec & {
		type:     _spec.service.type
		selector: _spec.selectorLabels
		ports: [
			{
				name:       "http"
				port:       _spec.service.externalPort
				targetPort: "\(name)"
				protocol:   "TCP"
			},
			{
				name:       "http-metrics"
				port:       _spec.service.metricsPort
				targetPort: "\(name)"
				protocol:   "TCP"
			},
			{
				name:       "grpc"
				port:       _spec.service.grpcPort
				targetPort: "\(name)"
				protocol:   "TCP"
			},
		]
	}
}
