package namespace

#AppNamespaceSpec: {
	name: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	role: *"namespace-admin" | "cluster-admin" | string
	labels: "tenant.toolkit.fluxcd.io/name":      *name | string
	annotations: "tenant.toolkit.fluxcd.io/role": *role | string
}

#AppNamespace: {
	spec: #AppNamespaceSpec

	resources: {
		"\(spec.name)-namespace":      #Namespace & {_spec:      spec}
		"\(spec.name)-serviceaccount": #ServiceAccount & {_spec: spec}
	}

	if spec.role == "namespace-admin" {
		resources: "\(spec.name)-rolebinding": #RoleBinding & {_spec: spec}
	}

	if spec.role == "cluster-admin" {
		resources: "\(spec.name)-clusterrolebinding": #ClusterRoleBinding & {_spec: spec}
	}
}
