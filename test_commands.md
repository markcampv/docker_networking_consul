# Baseline: should show v1-dc1
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .

# Kill dc1 backend to force failover
docker compose stop app-backend-dc1 proxy-backend-dc1

# A few seconds later: should show v1-dc2 via gateways
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .

# Bring dc1 back
docker compose up -d --no-deps app-backend-dc1 proxy-backend-dc1
# After health recovers: should return to v1-dc1
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:6060/ | jq .

# See resolver and defaults are in place
docker compose exec consul-client-dc1-1 consul config read -kind service-resolver -name backend

docker compose exec consul-client-dc1-1 consul config read -kind service-defaults -name backend

# List services (should include mesh-gateway)
docker compose exec consul-client-dc1-1 consul catalog services

# Check gateway admins
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:19010/listeners | head -n 40


docker compose exec consul-client-dc2-1 curl -s http://127.0.0.1:19010/listeners | head -n 40

# Look for endpoints pointing to dc2 backend sidecar/mesh path
docker compose exec consul-client-dc1-1 curl -s http://127.0.0.1:19000/clusters | grep -n 'backend' -n

docker compose exec proxy-frontend sh -lc 'curl -s -X POST http://127.0.0.1:19000/clusters?format=json' > frontend_cluster.txt

# discovery chain

curl -s localhost:8500/v1/discovery-chain/backend?dc=dc1 | jq

#  Set log level

docker compose exec mesh-gateway-dc1 sh -lc 'curl -s -X POST http://127.0.0.1:19000/logging?level=debug'

docker compose exec mesh-gateway-dc2 sh -lc 'curl -s -X POST http://127.0.0.1:19010/logging?level=debug'


-------------------------------------------------
Two clusters for backend on the frontend sidecar:

failover-target~0 … ::172.21.0.9:21000 → your local dc1 backend sidecar (active / healthy; has requests).

failover-target~1 … ::172.21.0.10:8443 → the dc1 mesh-gateway endpoint (which will forward to dc2). Healthy but rq_total::0 so far — expected until you actually fail over.