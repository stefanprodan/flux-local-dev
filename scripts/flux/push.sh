#!/bin/sh
set -o errexit

kubernetes_path='kubernetes'
cluster_name='local'
registry='localhost:5050'

diff_push() {
  artifact_name="flux-$1-sync"
  artifact_path=$2
  mkdir -p ./bin/${artifact_name}
  flux pull artifact oci://${registry}/${artifact_name}:${cluster_name} \
    -o ./bin/${artifact_name} &>/dev/null || mkdir -p ./bin/${artifact_name}/${artifact_path}
  if [[ $(git diff --no-index --stat ${artifact_path} ./bin/${artifact_name}/${artifact_path} ) != '' ]]; then
    flux push artifact oci://${registry}/${artifact_name}:${cluster_name} \
      --path="${artifact_path}" \
      --source="$(git config --get remote.origin.url)" \
      --revision="$(git rev-parse HEAD)"
  else
    echo "✔ no changes detected in ${artifact_path}"
  fi
  rm -rf ./bin/${artifact_name}
}

diff_push cluster ${kubernetes_path}/clusters/${cluster_name}
diff_push infra ${kubernetes_path}/infra
diff_push apps ${kubernetes_path}/apps
