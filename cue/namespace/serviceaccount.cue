package namespace

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_spec:      #AppNamespaceSpec
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:        "flux-\(_spec.name)"
		namespace:   _spec.name
		labels:      _spec.labels
		annotations: _spec.annotations
	}
}
