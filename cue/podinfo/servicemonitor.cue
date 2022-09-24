package podinfo

#serviceMonConfig: {
	enabled:  *false | bool
	interval: *"15s" | string
}

#ServiceMonitor: {
	_spec:      #AppSpec
	apiVersion: "monitoring.coreos.com/v1"
	kind:       "ServiceMonitor"
	metadata:   _spec.meta
	spec: {
		endpoints: [{
			path:     "/metrics"
			port:     "http-metrics"
			interval: _spec.serviceMonitor.interval
		}]
		namespaceSelector: matchNames: [_spec.meta.namespace]
		selector: matchLabels: _spec.meta.labels
	}
}
