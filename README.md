# Consul Service Mesh Docker Lab (v2) — 2 DCs + Failover (No Envoy Required)

This version uses **Envoy proxy** for sidecars. It spins up:
- **dc1**: 3 servers, 2 clients
  - `frontend` (calls `backend` via upstream on `127.0.0.1:5000`)
  - `backend` (v1-dc1)
- **dc2**: 3 servers, 1 client
  - `backend` (v1-dc2)
- A `service-resolver` preferring dc1 for `backend` and failing over to dc2.

## Start
```bash
docker compose up -d --build
docker compose run --rm setup-config
```

UIs:
- dc1: http://localhost:8500
- dc2: http://localhost:18500

## Test path
```bash
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .
```

## Failover
```bash
docker compose stop app-backend-dc1 proxy-backend-dc1
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .
```

## Clean up
```bash
docker compose down -v
```
