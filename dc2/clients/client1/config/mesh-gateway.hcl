service {
  name = "mesh-gateway"
  kind = "mesh-gateway"
  port = 8443
  checks = [{
    name     = "mesh-gateway-tcp"
    tcp      = "127.0.0.1:8443"
    interval = "5s"
    timeout  = "2s"
  }]
}