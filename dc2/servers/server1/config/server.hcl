# ---------- Networking ----------
# Advertise the container's eth0 IP (prevents 0.0.0.0 advertise mistakes)
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Listen on all interfaces inside the container
bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"

# ---------- Datacenter / cluster ----------
server              = true
datacenter          = "dc2"
primary_datacenter  = "dc1"        # federation points back to dc1
bootstrap_expect    = 3

# Retry-join is handled on the CLI in docker-compose (so this file can be identical on all three)
# Example (if you prefer to keep it here, remove the CLI flags):
# retry_join = ["consul-server-dc2-1","consul-server-dc2-2","consul-server-dc2-3"]

# ---------- Connect / mesh gateways ----------
connect {
  enabled = true

  # Use mesh-gateway federation between DCs (do NOT set retry_join_wan / advertise_addr_wan)
  enable_mesh_gateway_wan_federation = true
}

primary_gateways = ["consul-client-dc1-1:8443"]
# ---------- ACLs ----------
# Leave off for this lab.
acl {
  enabled = false
}

# ---------- Telemetry / UI ----------
ui_config {
  enabled = true
}

# ---------- TLS for RPC ----------
# TLS certs are injected via docker-compose command flags so this file is identical on all three.
# If you prefer node-specific configs instead of CLI flags, replace with:
#
tls {
    defaults {
    ca_file   = "/pki/ca/ca.pem"
    cert_file = "/pki/agents/server-dc2-1.pem"
    key_file  = "/pki/agents/server-dc2-1-key.pem"
  }
  internal_rpc {
    verify_incoming        = false
    verify_outgoing        = false
    verify_server_hostname = false
  }
  grpc {
    verify_incoming = false
  }
}

