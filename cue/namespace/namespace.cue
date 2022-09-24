package namespace

import (
	corev1 "k8s.io/api/core/v1"
)

#Namespace: corev1.#Namespace & {
	_spec:      #AppNamespaceSpec
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name:        _spec.name
		labels:      _spec.labels
		annotations: _spec.annotations
	}
}
