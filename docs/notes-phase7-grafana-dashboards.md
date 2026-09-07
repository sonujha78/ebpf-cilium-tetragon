# Phase 7 (part 3) — Grafana Dashboards

## Dashboard 1: Cilium/Hubble Network Observability
Screenshot: docs/screenshots/phase7-grafana-dashboard1-requests-drops.png

Panels:
1. **Requests per Service Pair**
   `sum(rate(hubble_flows_processed_total{verdict="FORWARDED"}[2m])) by (source, destination)`
2. **Dropped/Denied connections over time**
   `sum(rate(hubble_drop_total[1m])) by (reason)`
   Shows POLICY_DENIED and UNSUPPORTED_L3_PROTOCOL reasons live.

## Dashboard 2: Cilium/Hubble Network Observability-2
Screenshot: docs/screenshots/phase7-grafana-dashboard2-dns.png

Panel:
3. **DNS Query Visibility**
   `sum(rate(hubble_dns_queries_total[1m])) by (query)`
   Shows DNS queries (e.g. backend.demo.svc.cluster.local.) resolved
   inside the cluster.

## Important fix: DNS visibility
DNS metrics initially showed no data even with `hubble.metrics.enabled`
including `dns:query;ignoreAAAA`. Root cause: Cilium only inspects DNS
traffic at L7 (and thus can report DNS metrics) when traffic is routed
through its DNS proxy. This requires a visibility annotation on the pod
(or an explicit policy with DNS rules):

    kubectl patch deployment frontend -n demo --type='json' \
      -p='[{"op":"add","path":"/spec/template/metadata/annotations",
      "value":{"io.cilium.proxy-visibility":"<Egress/53/UDP/DNS>"}}]'

After this, `hubble_dns_queries_total`, `hubble_dns_responses_total`, and
`hubble_dns_response_types_total` started appearing immediately.
