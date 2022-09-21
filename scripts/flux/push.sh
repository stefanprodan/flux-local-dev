#!/bin/sh
set -o errexit

cluster_artifact='flux-cluster-sync'
apps_artifact='flux-apps-sync'
infra_artifact='flux-infra-sync'
kubernetes_path='kubernetes'
cluster_name='local'

flux push artifact oci://localhost:5050/${cluster_artifact}:${cluster_name} \
  --path="${kubernetes_path}/clusters/local" \
  --source="$(git config --get remote.origin.url)" \
  --revision="$(git rev-parse HEAD)"

flux push artifact oci://localhost:5050/${infra_artifact}:${cluster_name} \
  --path="${kubernetes_path}/infra" \
  --source="$(git config --get remote.origin.url)" \
  --revision="$(git rev-parse HEAD)"

flux push artifact oci://localhost:5050/${apps_artifact}:${cluster_name} \
  --path="${kubernetes_path}/apps" \
  --source="$(git config --get remote.origin.url)" \
  --revision="$(git rev-parse HEAD)"
