package main

import (
	"tool/cli"
	"encoding/yaml"
	"text/tabwriter"

	kubernetes "k8s.io/apimachinery/pkg/runtime"
)

// The resources map holds the Kubernetes objects of the apps and their namespaces.
resources: [ID=_]: kubernetes.#Object
for t in objects {
	resources: t.resources
}

command: gen: {
	task: print: cli.Print & {
		text: yaml.MarshalStream([ for x in resources {x}])
	}
}

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"RESOURCE \tAPI VERSION",
			for r in resources {
				if r.metadata.namespace == _|_ {
					"\(r.kind)/\(r.metadata.name) \t\(r.apiVersion)"
				}
				if r.metadata.namespace != _|_ {
					"\(r.kind)/\(r.metadata.namespace)/\(r.metadata.name)  \t\(r.apiVersion)"
				}
			},
		])
	}
}
