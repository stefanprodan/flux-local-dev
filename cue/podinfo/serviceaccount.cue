package podinfo

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_spec:      #AppSpec
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   _spec.meta
}
