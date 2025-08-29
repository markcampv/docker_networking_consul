service {
  name = "backend"
  port = 7000
  connect { sidecar_service {} }
  check {
    name     = "http-backend"
    http     = "http://127.0.0.1:7000/healthz"
    interval = "5s"
    timeout  = "2s"
  }
}
