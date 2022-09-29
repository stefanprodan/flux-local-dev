#!/usr/bin/env bash
set -o errexit

cluster_name='local'
registry='localhost:5050'
cue_dist="dist"
cue_bin="bin"

diff_push() {
  artifact_name="flux-$1-sync"
  artifact_path=$2
  mkdir -p ${cue_bin}/${artifact_name}
  flux pull artifact oci://${registry}/${artifact_name}:${cluster_name} \
    -o ${cue_bin}/${artifact_name} &>/dev/null || mkdir -p ${cue_bin}/${artifact_name}/${artifact_path}
  if [[ $(git diff --no-index --stat ${artifact_path} ${cue_bin}/${artifact_name}/${artifact_path} ) != '' ]]; then
    flux push artifact oci://${registry}/${artifact_name}:${cluster_name} \
      --path="${artifact_path}" \
      --source="$(git config --get remote.origin.url)" \
      --revision="$(git rev-parse HEAD)"
  else
    echo "✔ no changes detected in the apps manifests"
  fi
  rm -rf ${cue_bin}
}

cd cue
mkdir -p ${cue_dist}
cue gen > "${cue_dist}/manifests.yaml"
diff_push cue-apps ${cue_dist}
rm -rf ${cue_dist}
