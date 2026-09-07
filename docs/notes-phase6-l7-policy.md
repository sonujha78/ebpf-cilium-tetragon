# Phase 6 (part 2) — L7 HTTP-aware CiliumNetworkPolicy

## Goal
Allow frontend -> backend on specific HTTP paths (/get, /headers) while
blocking a sensitive/admin-like path (/status/500), enforced at the HTTP
layer by Cilium's eBPF+Envoy L7 proxy, not by the application.

## Important fix
Initially the L7 policy had no effect because an older L4-only policy
(`02-allow-frontend-to-backend.yaml`, port 8080, no HTTP rules) was still
present. Cilium unions all matching ingress rules for an endpoint, so the
L4-only rule allowed all HTTP paths regardless of the L7 policy. Removed it
so only the L7 policy governs frontend -> backend traffic:

    kubectl delete -f manifests/network-policies/02-allow-frontend-to-backend.yaml

## Policy (04-l7-http-allow-get-block-status.yaml)
Allows only GET /get and GET /headers on port 8080 from frontend to backend.
Any other path (e.g. /status/500) is denied at L7.

## Verification

    # allowed path
    kubectl exec -n demo deploy/frontend -- curl -s -m 3 -o /dev/null -w "%{http_code}\n" http://backend/get
    => 200

    # blocked path (never reaches app, Envoy returns 403)
    kubectl exec -n demo deploy/frontend -- curl -s -m 3 -o /dev/null -w "%{http_code}\n" http://backend/status/500
    => 403

## Hubble flow confirmation (docs/screenshots/phase6-l7-hubble-cli.txt)

    GET /get         -> http-request FORWARDED -> response 200
    GET /status/500  -> http-request DROPPED   -> response 403

The DROPPED verdict on the HTTP request itself (not just TCP) confirms
enforcement happens at Layer 7, inspecting the actual HTTP path, before
the request reaches the backend pod's application.
