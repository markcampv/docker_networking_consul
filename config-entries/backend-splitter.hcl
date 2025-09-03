Kind = "service-splitter"
Name = "backend"
Splits = [
  {
        weight  = 50,
        service = "backend-dc1",
      },
      { weight  = 50,
        service = "backend-dc2",
      },
]