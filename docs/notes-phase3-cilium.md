# Phase 3 — Cilium Install

Installed via cilium-cli, auto-detected kind cluster settings.
cilium install --version 1.16.3
--set kubeProxyReplacement=true
--set k8sServiceHost=ebpf-cluster-control-plane
--set k8sServicePort=6443

## Status after install
- Cilium: OK
- Operator: OK
- Envoy DaemonSet: OK
- Cluster Pods: 3/3 managed by Cilium
- Helm chart version: 1.16.3

## Node status (all Ready after CNI install)
NAME STATUS ROLES VERSION
ebpf-cluster-control-plane Ready control-plane v1.30.0
ebpf-cluster-worker Ready <none> v1.30.0
ebpf-cluster-worker2 Ready <none> v1.30.0
All kube-system pods (coredns, cilium, cilium-envoy, cilium-operator) Running.
