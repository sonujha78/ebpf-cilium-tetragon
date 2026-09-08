# Phase 10 — Performance Comparison (Sidecar vs eBPF)

## Test setup
Service-to-service call: `frontend` -> `backend` (GET /get), 50 sequential
requests, measured with curl's built-in `%{time_total}` from inside the
frontend pod. All 4 CiliumNetworkPolicies (L3/L4 + L7) were active during
the test, so these numbers include Cilium's full enforcement path.

    kubectl exec -n demo deploy/frontend -- sh -c '
    for i in $(seq 1 50); do
      curl -s -o /dev/null -w "%{time_total}\n" http://backend/get
    done'

## Cilium eBPF results (measured, this cluster)

| Metric  | Value   |
|---------|---------|
| Requests| 50      |
| Min     | 2.03 ms |
| Max     | 7.97 ms |
| Average | 3.40 ms |

No sidecar proxy is in the data path. Traffic goes: pod -> veth ->
eBPF program (attached at the network interface / socket layer) ->
destination pod, entirely inside the kernel. For the L7 policy on the
backend, Cilium's embedded Envoy (also running as a per-node DaemonSet,
not a per-pod sidecar) inspects the HTTP request - a similar redirect
cost to a sidecar's proxy hop, but incurred once per node rather than
twice per request (once for the client-side sidecar, once for the
server-side sidecar).

## Istio sidecar (documented / industry-reported numbers)
Istio was not installed on this cluster during this test (kind's
resource limits made running Cilium + Tetragon + Prometheus + Istio side
by side impractical without a larger machine). Instead, this section
uses publicly documented Istio benchmark figures (Istio's own
performance documentation and multiple third-party CNCF benchmarks) as
an approximate baseline:

| Metric                        | Typical reported value       |
|--------------------------------|------------------------------|
| Added p50 latency per hop      | ~1-2 ms per sidecar traversal|
| Added p99 latency per hop      | ~5-10 ms per sidecar traversal|
| Extra network hops per request | 2 (client sidecar + server sidecar) |
| CPU overhead per proxy         | ~0.5 vCPU per sidecar at moderate load |
| Memory overhead per proxy      | ~50-100 MB per sidecar (Envoy) |

Since a typical service-to-service call in a sidecar mesh traverses
*two* Envoy proxies (egress from caller's sidecar, ingress to callee's
sidecar), the cumulative added latency is roughly double the per-hop
figure - commonly cited as 2-10ms+ of pure proxying overhead on top of
the application's own processing time, plus two extra TCP/loopback hops
per request.

## Why eBPF avoids the extra hop
- **Sidecar mesh**: request leaves the app -> loopback to local Envoy
  sidecar -> out over the network -> destination node -> loopback to
  destination's Envoy sidecar -> app. That is 2 extra proxy hops and
  2 extra TLS/HTTP parsing passes per request, each sidecar running as
  its own userspace process needing its own CPU/memory allocation per
  pod.
- **Cilium eBPF**: L3/L4 enforcement happens via eBPF programs attached
  directly to the network interfaces/sockets in the kernel - no proxy
  process, no extra hop, decisions made in-kernel in nanoseconds.
  Even where L7 inspection is needed (our HTTP policy), Cilium uses a
  single Envoy instance *per node* (not per pod), so the number of proxy
  instances scales with node count, not with the number of pods/services
  - and there is still no double-hop, since only the policy-bearing side
  needs inspection.

## Caveat
This comparison mixes a measured result (Cilium, this cluster) with
documented figures (Istio, from public benchmarks) rather than two
measurements on identical hardware/load, per the task's "even
approximate" allowance. For a fully apples-to-apples number, both
meshes would need to be benchmarked on the same nodes under the same
generated load (e.g. with `hey` or `wrk`), which was out of scope given
this machine's resource constraints.
