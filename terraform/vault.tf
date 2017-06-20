provider "vault" {}

resource "vault_mount" "test" {
  path        = "test"
  type        = "pki"
  description = "Test ca"
}

resource "vault_generic_secret" "initialize_ca_test" {
  depends_on = ["vault_mount.test"]
  path       = "test/root/generate/internal"

  data_json = <<EOF
  {
    "common_name": "test",
    "ttl": "48h",
    "key_bits": "4096"
  }
EOF
}

resource "vault_generic_secret" "test_role" {
  depends_on = ["vault_mount.test"]
  path       = "test/roles/test_role"

  data_json = <<EOF
  {
    "allow_localhost": false,
    "allow_bare_domains": true,
    "allow_subdomains": false,
    "allowed_domains": "test",
    "server_flag": true,
    "client_flag": false,
    "ttl": "30m",
    "key_bits": 4096,
  }
EOF
}

resource "vault_generic_secret" "test_role_with_lease" {
  depends_on = ["vault_mount.test"]
  path       = "test/roles/test_role"

  data_json = <<EOF
  {
    "allow_localhost": false,
    "allow_bare_domains": true,
    "allow_subdomains": false,
    "allowed_domains": "test",
    "server_flag": true,
    "client_flag": false,
    "ttl": "30m",
    "key_bits": 4096,
    "generate_lease": true
  }
EOF
}

resource "vault_generic_secret" "child_token" {
  path = "auth/token/create"

  data_json = <<EOF
  {
    "id": "child_token",
    "policies": ["test"],
    "renewable": "true",
    "ttl": "30m"
  }
EOF
}

resource "vault_policy" "test" {
  name = "test"

  policy = <<EOT
path "test/issue/test_role" {
  policy = "write"
}
EOT
}
