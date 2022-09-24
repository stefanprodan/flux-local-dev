package podinfo

import (
	autoscaling "k8s.io/api/autoscaling/v2beta2"
)

#hpaConfig: {
	enabled:     *false | bool
	cpu:         *99 | int
	memory:      *"" | string
	minReplicas: *1 | int
	maxReplicas: *1 | int
}

#HorizontalPodAutoscaler: autoscaling.#HorizontalPodAutoscaler & {
	_spec:      #AppSpec
	apiVersion: "autoscaling/v2beta2"
	kind:       "HorizontalPodAutoscaler"
	metadata:   _spec.meta
	spec: {
		scaleTargetRef: {
			apiVersion: "apps/v1"
			kind:       "Deployment"
			name:       _spec.meta.name
		}
		minReplicas: _spec.hpa.minReplicas
		maxReplicas: _spec.hpa.maxReplicas
		metrics: [
			if _spec.hpa.cpu > 0 {
				{
					type: "Resource"
					resource: {
						name: "cpu"
						target: {
							type:               "Utilization"
							averageUtilization: _spec.hpa.cpu
						}
					}
				}
			},
			if _spec.hpa.memory != "" {
				{
					type: "Resource"
					resource: {
						name: "memory"
						target: {
							type:         "AverageValue"
							averageValue: _spec.hpa.memory
						}
					}
				}
			},
		]
	}
}
