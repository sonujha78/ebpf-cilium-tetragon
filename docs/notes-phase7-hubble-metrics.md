# Phase 7 (part 1) — Hubble Metrics Enabled

## Values file (grafana/hubble-metrics-values.yaml)

    hubble:
      metrics:
        enabled:
          - dns
          - drop
          - tcp
          - flow
          - port-distribution
          - icmp
          - "http"
        enableOpenMetrics: true

## Apply

    helm upgrade cilium cilium/cilium --version 1.16.3 \
      --namespace kube-system \
      --reuse-values \
      -f grafana/hubble-metrics-values.yaml
    kubectl -n kube-system rollout restart daemonset cilium

## Note
First attempt used `--set hubble.metrics.enabled="{...}"` which silently
failed (shell mangled the curly braces / array syntax). Switched to a
values YAML file passed with `-f`, which is more reliable for complex
values like lists.

## Verification
Port-forwarded cilium-agent pod on 9965 and curled /metrics — confirmed
hubble_flows_processed_total, hubble_icmp_total, hubble_lost_events_total
and other Hubble metrics are being exposed in Prometheus format.
