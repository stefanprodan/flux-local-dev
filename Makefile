# Flux local dev environment with Docker and Kubernetes KIND
# Requirements:
# - Docker
# - Homebrew

.PHONY: up
up: cluster-up flux-push flux-up ## Create the local cluster and registry, install Flux and the cluster addons
	kubectl -n flux-system wait kustomization/cluster-sync --for=condition=ready --timeout=5m
	kubectl -n flux-system wait kustomization/apps-sync --for=condition=ready --timeout=5m

.PHONY: down
down: cluster-down ## Delete the local cluster and registry

.PHONY: sync
sync: flux-push ## Build, push and reconcile the manifests
	flux reconcile ks cluster-sync --with-source
	flux reconcile ks apps-sync --with-source

.PHONY: check
check: ## Check if the NGINX ingress self-signed TLS works
	curl --insecure https://podinfo.flux.local

.PHONY: tools
tools: ## Install Kubernetes kind, kubectl, FLux CLI and other tools with Homebrew
	brew bundle

.PHONY: validate
validate: ## Validate the Kubernetes manifests (including Flux custom resources)
	scripts/test/validate.sh

.PHONY: cluster-up
cluster-up:
	scripts/kind/up.sh

.PHONY: cluster-down
cluster-down:
	scripts/kind/down.sh

.PHONY: flux-up
flux-up:
	scripts/flux/up.sh

.PHONY: flux-down
flux-down:
	scripts/flux/down.sh

.PHONY: flux-push
flux-push:
	scripts/flux/push.sh

.PHONY: cue-mod
cue-mod:
	@cd cue && go get -u k8s.io/api/... && cue get go k8s.io/api/...

.PHONY: cue-gen
cue-gen: ## Print the CUE generated objects
	@cd cue && cue fmt ./... && cue vet --all-errors --concrete ./...
	@cd cue && cue gen

.PHONY: cue-ls
cue-ls: ## List the CUE generated objects
	@cd cue && cue ls

.PHONY: cue-push
cue-push: ## Push the CUE generated manifests to the registry
	scripts/flux/push-cue.sh

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
