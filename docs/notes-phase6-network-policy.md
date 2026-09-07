# Phase 6 — CiliumNetworkPolicy (L3/L4)

## Policies applied

1. `01-default-deny.yaml` — default-deny all ingress in `demo` namespace
2. `02-allow-frontend-to-backend.yaml` — explicit allow frontend -> backend on port 8080
3. `03-allow-backend-to-database.yaml` — explicit allow backend -> database on port 5432

frontend -> database has NO explicit allow rule, so it is denied by the
default-deny policy.

## Apply

    kubectl apply -f manifests/network-policies/

## Enforcement proof

    # allowed - returns JSON
    kubectl exec -n demo deploy/frontend -- curl -s -m 3 http://backend/get

    # blocked - curl exits with code 28 (timeout), request never reaches app
    kubectl exec -n demo deploy/frontend -- curl -s -m 3 http://database:5432

## Hubble UI confirmation

See docs/screenshots/phase6-hubble-l3l4-drop.png

- frontend -> backend:8080 => verdict: forwarded
- frontend -> database:5432 => verdict: dropped

This confirms enforcement happens at the eBPF/kernel layer before traffic
reaches the destination pod's application code, with zero changes to any
application.
