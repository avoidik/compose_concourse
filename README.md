# Concourse

This is the compilation of proposed [docker-compose solution](https://concourse.ci/docker-repository.html) and my own experience.

### Prerequisites

- virtualbox
- bash
- docker-machine binary
- docker-compose binary
- docker binary

### How to start

1. `scripts/certs.sh`
1. `scripts/create-machine.sh`
1. change `ENV_CONCOURSE_URL` variable as suggested in previous step (check console output)
1. `scripts/create-network.sh`
1. `scripts/up-compose.sh docker-compose.yml`

### How to login

Credentials are set in `env.config` during spin-up, user/user by default.

### Recycle

1. `scripts/down-compose.sh docker-compose.yml`
1. `scripts/up-compose.sh docker-compose.yml`

### Cleanup

Soft way
```
scripts/prune.sh
scripts/down-compose.sh docker-compose.yml -v --remove-orphans --rmi all
scripts/kill-machine.sh
```
Hard way
```
scripts/kill-machine.sh
```

Additional scripts
1. `prune.sh` - clean up docker internals inside docker machine, like `scripts/prune.sh`
1. `cmd.sh` - execute command in docker machine context, like `scripts/cmd.sh docker ps`
1. `compose.sh` - execute docker compose command in docker machine context, like `scripts/compose.sh ps`

### Vault

1. `scripts/compose.sh -f docker-compose-vault.yml up`
1. init, unseal via webui (1 share, 1 threshold)
1. create policy and generate token (see below)
1. terminate with CTRL+C
1. `scripts/compose.sh -f docker-compose-vault.yml -f docker-compose-secrets.yml up`
1. unseal vault

Create policy and token

```
export VAULT_ADDR="http://$(docker-machine ip concourse):8200"
export VAULT_TOKEN="..."

vault policy write concourse policy/concourse.hcl
vault token create -policy=concourse -period=10m -id=concourse-token
```

Cleanup

```
scripts/compose.sh -f docker-compose-secrets.yml -f docker-compose-vault.yml down -v --remove-orphans
```

### Fly basics

Enable secrets

```
vault secrets enable -path=concourse -version=1 kv
vault kv put concourse/main/helloworld/user name=foo
vault kv put concourse/main/helloworld/password value=bar
```

Login

```
fly --target tutorial login --concourse-url http://<url>:8080
fly --target tutorial sync
```

Create pipeline

```
fly --target tutorial set-pipeline -c fly/pipeline.yml -p helloworld
```

Unpause pipeline and job

```
fly --target tutorial unpause-pipeline -p helloworld
fly --target tutorial unpause-job --job helloworld/hello-world
```

Trigger the job

```
fly --target tutorial trigger-job --job helloworld/hello-world -w
```

Check builds history

```
fly --target tutorial builds
fly --target tutorial watch -j helloworld/hello-world -b 2
```

Destroy pipeline

```
fly --target tutorial destroy-pipeline -p helloworld
```

### Debug

```
winpty docker run --name=worker --user=root --rm -e CONCOURSE_TSA_HOST=web -e CONCOURSE_WORK_DIR=/opt/concourse/worker --network=concourse --privileged -v "//c/Projects/compose_concourse/keys:/concourse-keys" --entrypoint //bin/bash -it concourse/concourse
```
