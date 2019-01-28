#!/bin/bash

set -e

CONSUL_ADDR="http://$(docker-machine ip concourse):8500"

export VAULT_ADDR="http://$(docker-machine ip concourse):8200"

cget() { curl -sf "${CONSUL_ADDR}/v1/kv/service/vault/$1?raw"; }

if [[ -z "$(cget root-token)" ]]; then
  echo "Initialize Vault"
  vault operator init \
    -key-shares=1 \
    -key-threshold=1 | tee /tmp/vault.init > /dev/null

  # Store master keys in consul for operator to retrieve and remove
  COUNTER=1
  grep '^Unseal' < /tmp/vault.init | awk '{print $4}' | while read -r key; do
    curl -sfX PUT "${CONSUL_ADDR}/v1/kv/service/vault/unseal-key-$COUNTER" -d "$key"; echo
    COUNTER=$((COUNTER + 1))
  done

  PARSED_TOKEN="$(grep '^Initial' < /tmp/vault.init | awk '{print $4}')"

  export ROOT_TOKEN="$PARSED_TOKEN"
  curl -sfX PUT "${CONSUL_ADDR}/v1/kv/service/vault/root-token" -d "$ROOT_TOKEN"; echo

  echo "Remove master keys from disk"
  shred /tmp/vault.init
else
  echo "Vault has already been initialized, skipping."
fi

echo "Unsealing Vault"
vault operator unseal "$(cget unseal-key-1)" > /dev/null
#vault operator unseal "$(cget unseal-key-2)" > /dev/null
#vault operator unseal "$(cget unseal-key-3)" > /dev/null

echo "Vault setup complete."

instructions() {
  cat <<EOF

Root token is:
$(cget root-token)

EOF
  exit 1
}

instructions
