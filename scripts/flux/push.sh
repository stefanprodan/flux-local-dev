#!/usr/bin/env bash
set -o errexit

kubernetes_path='kubernetes'
cluster_name='local'
registry='localhost:5050'

diff_push() {
  artifact_name=$1
  artifact_path=$2

  flux diff artifact oci://${artifact_name} \
    --path="${artifact_path}" &>/dev/null || diff_exit_code=$?

  if [[  ${diff_exit_code} -ne 0 ]]; then
    flux_output=$(flux push artifact oci://${artifact_name} \
      --path="${artifact_path}" \
      --source="$(git config --get remote.origin.url)" \
      --revision="$(git rev-parse HEAD)" 2>&1) || exit_code=$?

     oci_url=$(echo ${flux_output} | tail -n1 | awk '/to/{print $NF}')
  else
    echo "✔ no changes detected in ${artifact_path}"
    return
  fi

  if [[  ${exit_code} -ne 0 ]]; then
    echo ${flux_output}
    exit 1
  fi

  echo "✔ pushed to ${oci_url}"
}

diff_push "${registry}/flux-cluster-sync:local" "${kubernetes_path}/clusters/${cluster_name}"
diff_push "${registry}/flux-infra-sync:local" "${kubernetes_path}/infra"
diff_push "${registry}/flux-apps-sync:local" "${kubernetes_path}/apps"
