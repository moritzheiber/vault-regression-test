vault {
  address     = "http://vault:8200"
  renew_token = true

  ssl {
    enabled = false
  }
}

exec {
  command = "/bin/sh -c \"cat /certs.json && sleep 3600\""
}

template {
  source      = "/certs.json.ctmpl"
  destination = "/certs.json"

  wait {
    min = "5s"
  }
}
