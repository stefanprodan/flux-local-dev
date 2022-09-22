#!/usr/bin/env bash
set -o errexit

cluster_path='kubernetes/clusters/local/flux-system'
flux_ks='flux-sync'

ec=0
flux get ks ${flux_ks} 2>/dev/null || ec=1

if [ "${ec}" -eq 1 ]; then
  echo "starting bootstrap"
  flux install --components=source-controller,kustomize-controller \
    --registry=docker.io/fluxcd

  kubectl apply -k "${cluster_path}"
  kubectl -n flux-system wait kustomization/${flux_ks} --for=condition=ready --timeout=5m
fi
