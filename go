#!/bin/bash

set -ux

export VAULT_ADDR="http://localhost:8200"
export VAULT_ROOT_TOKEN="root_token"
export VAULT_CHILD_TOKEN="child_token"

_shutdown() {
  docker-compose kill
  docker-compose rm -fv
}

_prefill() {
  (
    cd terraform/

    terraform init
    VAULT_TOKEN="${VAULT_ROOT_TOKEN}" terraform apply

    rm -rf .terraform terraform.tfstate*
  )
}

_build() {
  docker build -t test-service -f Dockerfile.service .
}

run() {
  _build

  docker-compose up -d vault
  _prefill

  trap _shutdown TERM INT EXIT
  docker-compose up service
}

usage() {
  echo "Usage: ${0} run"
  exit 0
}

arg=${1:-}
shift || true
case ${arg} in
  run) run ;;
  *) usage ;;
esac
