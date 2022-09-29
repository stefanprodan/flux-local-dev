package podinfo

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	_spec:           #AppSpec
	_serviceAccount: string
	apiVersion:      "apps/v1"
	kind:            "Deployment"
	metadata:        _spec.meta
	spec:            appsv1.#DeploymentSpec & {
		if !_spec.hpa.enabled {
			replicas: _spec.replicas
		}
		strategy: {
			type: "RollingUpdate"
			rollingUpdate: maxUnavailable: 1
		}
		selector: matchLabels: _spec.selectorLabels
		template: {
			metadata: {
				labels: _spec.selectorLabels
				if !_spec.serviceMonitor.enabled {
					annotations: {
						"prometheus.io/scrape": "true"
						"prometheus.io/port":   "\(_spec.service.metricsPort)"
					}
				}
			}
			spec: corev1.#PodSpec & {
				terminationGracePeriodSeconds: 15
				serviceAccountName:            _serviceAccount
				containers: [
					{
						name:            "podinfo"
						image:           "\(_spec.image.repository):\(_spec.image.tag)"
						imagePullPolicy: _spec.image.pullPolicy
						command: [
							"./podinfo",
							"--port=\(_spec.service.httpPort)",
							"--port-metrics=\(_spec.service.metricsPort)",
							"--grpc-port=\(_spec.service.grpcPort)",
							"--level=\(_spec.logLevel)",
							if _spec.cache != _|_ {
								"--cache-server=\(_spec.cache)"
							},
							for b in _spec.backends {
								"--backend-url=\(b)"
							},
						]
						ports: [
							{
								name:          "http"
								containerPort: _spec.service.httpPort
								protocol:      "TCP"
							},
							{
								name:          "http-metrics"
								containerPort: _spec.service.metricsPort
								protocol:      "TCP"
							},
							{
								name:          "grpc"
								containerPort: _spec.service.grpcPort
								protocol:      "TCP"
							},
						]
						livenessProbe: {
							httpGet: {
								path: "/healthz"
								port: "http"
							}
						}
						readinessProbe: {
							httpGet: {
								path: "/readyz"
								port: "http"
							}
						}
						volumeMounts: [
							{
								name:      "data"
								mountPath: "/data"
							},
						]
						resources: _spec.resources
						if _spec.securityContext != _|_ {
							securityContext: _spec.securityContext
						}
					},
				]
				if _spec.affinity != _|_ {
					affinity: _spec.affinity
				}
				if _spec.tolerations != _|_ {
					tolerations: _spec.tolerations
				}
				volumes: [
					{
						name: "data"
						emptyDir: {}
					},
				]
			}
		}
	}
}
