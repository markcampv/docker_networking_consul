service {
  name = "frontend"
  port = 6060
  connect {
    sidecar_service {
      proxy {
        upstreams = [
          { destination_name = "backend", local_bind_port = 5000 }
        ]
      }
    }
  }
  check {
    name     = "http-frontend"
    http     = "http://127.0.0.1:6060/healthz"
    interval = "5s"
    timeout  = "2s"
  }
}
