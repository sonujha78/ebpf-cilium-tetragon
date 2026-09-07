# Phase 8 (part 1) — Tetragon Install

## Install command

    helm repo add cilium https://helm.cilium.io/
    helm install tetragon cilium/tetragon --namespace kube-system

## Status
DaemonSet deployed on all 3 nodes (1 control-plane + 2 workers), all pods
2/2 Running.

    tetragon-2mjqf   ebpf-cluster-worker
    tetragon-67hft   ebpf-cluster-worker2
    tetragon-zswr8   ebpf-cluster-control-plane
