Kind = "service-resolver"
Name = "backend-dc2"

 redirect {
      service    = "backend"
      datacenter = "dc2"
    }