# Advertise the container's eth0 IP
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"

# Disable plaintext gRPC and move it to the TLS port
ports {
  grpc     = -1      # turn OFF plaintext
  grpc_tls = 8503    # use the same port you were exposing
}
connect { enabled = true }

acl { enabled = false }

tls {
  defaults {
    ca_file   = "/pki/ca/ca.pem"
    cert_file = "/pki/agents/client-dc2-1.pem"
    key_file  = "/pki/agents/client-dc2-1-key.pem"
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