# Phase 2 — Prerequisites + Multi-node kind Cluster

## Tools installed
- kubectl v1.37.0
- kind v0.23.0
- helm v3.21.4
- cilium-cli v0.20.0
- hubble CLI v1.19.4
- Docker v29.1.3 (pre-existing)

## Cluster config (kind-config/cluster.yaml)

    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    name: ebpf-cluster
    networking:
      disableDefaultCNI: true
      kubeProxyMode: "none"
    nodes:
      - role: control-plane
      - role: worker
      - role: worker

## Cluster created with

    kind create cluster --config cluster.yaml

## Result
3-node cluster created (1 control-plane, 2 workers). Nodes were
`NotReady` initially since no CNI was installed yet — resolved in
Phase 3 after Cilium install.
