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

Logs during failover

Front end:

mesh-gateway-dc1-1  | [2025-08-29 17:23:20.799][15][debug][upstream] [source/extensions/clusters/eds/eds.cc:428] EDS hosts or locality weights changed for cluster: backend.default.dc1.internal.e88fa74c-feed-3798-b55d-43bf8e4c010c.consul current hosts 1 priority 0
mesh-gateway-dc1-1  | [2025-08-29 17:23:20.799][15][trace][upstream] [source/common/upstream/upstream_impl.cc:2218] Local locality: 


Mesh gateway dc1

proxy-frontend-1  | [2025-08-29 17:23:20.799][1][debug][config] [source/extensions/config_subscription/grpc/new_grpc_mux_impl.cc:158] Received DeltaDiscoveryResponse for type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment at version 
proxy-frontend-1  | [2025-08-29 17:23:20.799][1][debug][upstream] [source/common/upstream/upstream_impl.cc:484] transport socket match, socket default selected for host with address 172.21.0.10:21000
proxy-frontend-1  | [2025-08-29 17:23:20.799][1][debug][upstream] [source/extensions/clusters/eds/eds.cc:428] EDS hosts or locality weights changed for cluster: failover-target~0~backend.default.dc1.internal.e88fa74c-feed-3798-b55d-43bf8e4c010c.consul current hosts 1 priority 0
proxy-frontend-1  | [2025-08-29 17:23:20.799][37][debug][upstream] [source/common/upstream/cluster_manager_impl.cc:1560] membership update for TLS cluster failover-target~0~backend.default.dc1.internal.e88fa74c-feed-3798-b55d-43bf8e4c010c.consul added 0 removed 0