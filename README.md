# Consul Service Mesh Docker Lab (v2) — 2 DCs + Failover 

Tested Consul version: hashicorp/consul:1.20.5

Tested Envoy version: 1.32.0

This version uses **Envoy proxy** for sidecars for Mesh gateway Wan Federation. It spins up:
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

Expected output(backend in DC1)

```bash
{
  "backend": {
    "dc_hint": "unknown",
    "service": "backend",
    "version": "v1-dc1"
  },
  "service": "frontend"
}
```
## Failover
```bash
docker compose stop app-backend-dc1 proxy-backend-dc1
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .
```

Expected output(backend in DC2)

```bash
{
  "backend": {
    "dc_hint": "unknown",
    "service": "backend",
    "version": "v1-dc2"
  },
  "service": "frontend"
}
```

## Split requests w/ Failover

Add the following config entries by running the command below: 

```bash
docker compose exec consul-server-dc1-1 sh -lc '  set -e
  consul config write /work/config-entries/virtual-defaults-dc1.hcl &&
  consul config write /work/config-entries/virtual-defaults-dc2.hcl &&
  consul config write /work/config-entries/backend-resolver-dc1.hcl &&
  consul config write /work/config-entries/backend-resolver-dc2.hcl &&
  consul config write /work/config-entries/backend-splitter.hcl
'
 ```  

Run a loop to observe the requests being split between backend dc1 and dc2

```bash
while true; do docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .; done
```

Expected output

```bash
{
  "backend": {
    "dc_hint": "unknown",
    "service": "backend",
    "version": "v1-dc1"
  },
  "service": "frontend"
}
{
  "backend": {
    "dc_hint": "unknown",
    "service": "backend",
    "version": "v1-dc2"
  },
  "service": "frontend"
}
{
  "backend": {
    "dc_hint": "unknown",
    "service": "backend",
    "version": "v1-dc1"
  },
  "service": "frontend"
}
```


## Clean up
```bash
docker compose down -v
```
