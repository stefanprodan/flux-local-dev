#!/usr/bin/env bash
set -o errexit

cluster_name='flux'
cluster_ingress_port='80'
cluster_ingress_tls_port='443'
reg_name='kind-registry'
reg_port='5050'
reg_internal_port='5000'

install_cluster() {
cat <<EOF | kind create cluster --name ${cluster_name} --wait 5m --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
      endpoint = ["http://${reg_name}:${reg_internal_port}"]
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: ${cluster_ingress_port}
        protocol: TCP
      - containerPort: 443
        hostPort: ${cluster_ingress_tls_port}
        protocol: TCP
EOF
}

register_registry() {
cat <<EOF | kubectl apply --server-side -f-
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    hostFromContainerRuntime: "${reg_name}:${reg_internal_port}"
    hostFromClusterNetwork: "${reg_name}:${reg_internal_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
}

# Create a registry container
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  echo "starting Docker registry on localhost:${reg_port}"
  docker run -d --restart=always -p "127.0.0.1:${reg_port}:${reg_internal_port}" \
    --name "${reg_name}" registry:2
fi

# Create a cluster with the local registry enabled
if [ "$(kind get clusters | grep ${cluster_name})" != "${cluster_name}" ]; then
  install_cluster
  register_registry
fi

# Connect the registry to the cluster network
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  echo "connecting the Docker registry to the cluster network"
  docker network connect "kind" "${reg_name}"
fi

