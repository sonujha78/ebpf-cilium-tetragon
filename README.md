# eBPF-Based Zero-Overhead Observability & Runtime Security

Stack: Cilium (eBPF CNI) + Hubble + Tetragon + Kubernetes + Grafana
No sidecars, no traditional userspace agents — enforcement, observability
and runtime security all happen at the Linux kernel level via eBPF.

## Progress
- [ ] Phase 1: Prerequisites installed
- [ ] Phase 2: Multi-node kind cluster (kube-proxy-free)
- [ ] Phase 3: Cilium installed (kube-proxy replacement mode)
- [ ] Phase 4: Hubble enabled
- [ ] Phase 5: Sample microservices deployed
- [ ] Phase 6: CiliumNetworkPolicy (L3/L4 + L7)
- [ ] Phase 7: Hubble + Prometheus + Grafana dashboards
- [ ] Phase 8: Tetragon + TracingPolicies
- [ ] Phase 9: Attack simulation
- [ ] Phase 10: Performance comparison (sidecar vs eBPF)
- [ ] Phase 11: Documentation
