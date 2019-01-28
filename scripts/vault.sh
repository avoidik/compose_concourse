#!/bin/bash

set -e

CONSUL_ADDR="http://$(docker-machine ip concourse):8500"

export VAULT_ADDR="http://$(docker-machine ip concourse):8200"

cget() { curl -sf "${CONSUL_ADDR}/v1/kv/service/vault/$1?raw"; }

export VAULT_TOKEN="$(cget root-token)"

exec vault "${@}"
