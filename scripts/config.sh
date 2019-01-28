#!/bin/bash

set -e

CONSUL_ADDR="http://$(docker-machine ip concourse):8500"

export VAULT_ADDR="http://$(docker-machine ip concourse):8200"

cget() { curl -sf "${CONSUL_ADDR}/v1/kv/service/vault/$1?raw"; }

export VAULT_TOKEN="$(cget root-token)"

# Create policy and token

vault policy write concourse policy/concourse.hcl
vault token revoke concourse-token
vault token create -policy=concourse -period=1h -id=concourse-token

# Enable secrets

vault secrets disable concourse/
vault secrets enable -path=concourse -version=1 kv
vault kv put concourse/main/helloworld/user name=foo
vault kv put concourse/main/helloworld/password value=bar
