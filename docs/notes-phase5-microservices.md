# Phase 5 — Sample Microservices

## Apps deployed (namespace: demo)

- **frontend** — curlimages/curl (used to make test calls)
- **backend** — mccutchen/go-httpbin (real HTTP API, has /get, /status/{code} etc.)
- **database** — curlimages/curl placeholder (port 5432 exposed, simulates a DB)

## Note on image choice

Originally planned `nicolaka/netshoot` and `kennethreitz/httpbin`, but kind
cluster nodes hit repeated `TLS handshake timeout` pulling large images from
Docker Hub. Switched to lightweight, actively maintained images
(`curlimages/curl`, `mccutchen/go-httpbin`) which pulled successfully.

## Deploy command

    kubectl apply -f manifests/microservices/apps.yaml

## Verify

    kubectl get pods -n demo -o wide

All 3 pods Running.

## Connectivity test (no network policy yet — succeeded)

    kubectl exec -n demo deploy/frontend -- curl -s http://backend/get

Returned valid JSON response from backend, confirming frontend -> backend
connectivity works before any CiliumNetworkPolicy is applied.
