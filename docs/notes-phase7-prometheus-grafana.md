# Phase 7 (part 2) — Prometheus + Grafana

## Installed via kube-prometheus-stack

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm install monitoring prometheus-community/kube-prometheus-stack \
      --namespace monitoring --create-namespace \
      --set grafana.adminPassword=admin123 \
      --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
      --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

Installs Prometheus, Grafana, Alertmanager, node-exporter, kube-state-metrics.
All pods Running in `monitoring` namespace.

## Hubble metrics Service (grafana/hubble-metrics-service.yaml)
Headless service exposing cilium-agent's :9965/metrics port, labeled
`k8s-app: hubble` in `kube-system`.

## ServiceMonitor (grafana/hubble-servicemonitor.yaml)
Tells Prometheus to scrape the hubble-metrics service every 15s.

## Verification
Prometheus Targets page (localhost:9090/targets) confirms:

    serviceMonitor/monitoring/hubble-metrics/0   3/3 up

All 3 Cilium agent pods (1 control-plane + 2 workers) are being scraped
successfully for Hubble metrics.

(Some default kube-prometheus-stack targets - kube-controller-manager,
kube-etcd, kube-scheduler - show DOWN, which is expected on kind clusters
since those components don't expose metrics externally by default. Not
relevant to this task.)
