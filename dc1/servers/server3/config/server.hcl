# ---------- Networking ----------
# Advertise the container's eth0 IP (prevents 0.0.0.0 advertise mistakes)
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Listen on all interfaces inside the container
bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"

# ---------- Datacenter / cluster ----------
server              = true
datacenter          = "dc1"
primary_datacenter  = "dc1"
bootstrap_expect    = 3

# Retry-join is handled on the CLI in docker-compose (so this file can be identical on all three)
# Example (if you prefer to keep it here, remove the CLI flags):
# retry_join = ["consul-server-dc1-1","consul-server-dc1-2","consul-server-dc1-3"]

# ---------- Connect / mesh gateways ----------
connect {
  enabled = true

  # Use mesh-gateway federation between DCs (do NOT set retry_join_wan / advertise_addr_wan)
  enable_mesh_gateway_wan_federation = true
}



# ---------- ACLs ----------
# Leave off for this lab. (Your config-writer job doesn’t need tokens this way.)
acl {
  enabled = false
}

# ---------- Telemetry / UI (optional but handy) ----------
ui_config {
  enabled = true
}

# ---------- TLS for RPC (certs come from CLI flags in compose) ----------
# We keep TLS file paths on the container command so this file is identical on all nodes.
# If you prefer to keep everything in HCL, create node-specific files and add:
#
tls {
  defaults {
    ca_file   = "/pki/ca/ca.pem"
    cert_file = "/pki/agents/server-dc1-3.pem"
    key_file  = "/pki/agents/server-dc1-3-key.pem"
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
