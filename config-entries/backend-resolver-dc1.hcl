Kind = "service-resolver"
Name = "backend-dc1"

 redirect {
      service    = "backend"
      datacenter = "dc1"
    }