# Concourse

Spin up standalone Concourse CI environment in Docker. Optionally with Vault secrets storage backend.

## Prerequisites

- virtualbox
- bash
- docker-machine binary (with boot2docker iso)
- docker-compose binary
- docker binary
- vault binary (optionally)

## Quickstart

1. `scripts/certs.sh` (generate certificates for Concourse)
1. `scripts/create-machine.sh` (create docker-machine)
1. `scripts/create-network.sh` (create docker overlay network)
1. `scripts/up-compose.sh docker-compose.yml` (start Concourse CI)
1. `scripts/pipeline_static.sh` (execute pipeline static)

### Execute pipeline (static)

Open Concourse URL `http://$(docker-machine ip concourse):8080`, download fly binary for your platform and then check `Fly basics` below.

Credentials are set in `env.config` during spin-up, user/user by default.

### Recycle

1. `scripts/down-compose.sh docker-compose.yml`
1. `scripts/up-compose.sh docker-compose.yml`

### Cleanup

Soft way

```bash
scripts/prune.sh
scripts/down-compose.sh docker-compose.yml -v --remove-orphans --rmi all
scripts/kill-machine.sh
```

Hard way

```bash
scripts/kill-machine.sh
```

Additional scripts:

1. `prune.sh` - clean up docker internals inside docker machine, like `scripts/prune.sh`
1. `cmd.sh` - execute command in docker machine context, like `scripts/cmd.sh docker ps`
1. `compose.sh` - execute docker compose command in docker machine context, like `scripts/compose.sh ps`

## Vault

Clean everything up after quickstart case

1. `scripts/certs.sh` (generate certificates for Concourse)
1. `scripts/create-machine.sh` (create docker-machine)
1. `scripts/create-network.sh` (create docker overlay network)
1. `scripts/compose.sh -f docker-compose-vault.yml -f docker-compose-secrets.yml up -d` (start Vault and Consul tiny stack altogether with Concourse CI)
1. `scripts/unseal.sh` (unseal after restart)
1. `scripts/config.sh` (create policy and generate token for Concourse, enable Vault secrets backend and write secrets data, see below)
1. `scripts/pipeline_vault.sh` (execute pipeline with Vault)

### Cleanup

```bash
scripts/compose.sh -f docker-compose-secrets.yml -f docker-compose-vault.yml down -v --remove-orphans
```

### Create policy and token

```bash
export VAULT_ADDR="http://$(docker-machine ip concourse):8200"
export VAULT_TOKEN="..."

vault policy write concourse policy/concourse.hcl
vault token create -policy=concourse -period=1h -id=concourse-token
```

### Enable secrets

```bash
vault secrets enable -path=concourse -version=1 kv
vault kv put concourse/main/helloworld/user name=foo
vault kv put concourse/main/helloworld/password value=bar
```

### Execute pipeline (Vault)

Open Concourse URL `http://$(docker-machine ip concourse):8080`, download fly binary for your platform and then check `Fly basics` below.

Credentials are set in `env.config` during spin-up, user/user by default.

## Fly basics

Login

```bash
fly --target tutorial login --concourse-url http://$(docker-machine ip concourse):8080 -b
fly --target tutorial sync
```

Create pipeline (static)

```bash
fly --target tutorial set-pipeline -c fly/pipeline_static.yml -p helloworld -n
```

Create pipeline (Vault)

```bash
fly --target tutorial set-pipeline -c fly/pipeline_vault.yml -p helloworld -n
```

Unpause pipeline and job

```bash
fly --target tutorial unpause-pipeline -p helloworld
fly --target tutorial unpause-job --job helloworld/hello-world
```

Trigger the job

```bash
fly --target tutorial trigger-job --job helloworld/hello-world -w
```

Check builds history

```bash
fly --target tutorial builds --print-table-headers
fly --target tutorial watch -j helloworld/hello-world -b 1
```

Check worker nodes

```bash
fly --target tutorial workers --print-table-headers
fly --target tutorial prune-workers -w ... # remove stalled worker if required
```

Destroy pipeline

```bash
fly --target tutorial destroy-pipeline -p helloworld -n
```
