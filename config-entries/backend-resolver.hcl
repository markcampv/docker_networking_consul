Kind = "service-resolver"
Name = "backend"


# Prefer local; fail over to the other DC
Failover = {
  "*" = {
    Datacenters = ["dc1", "dc2"]
  }
}