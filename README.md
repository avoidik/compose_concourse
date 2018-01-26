# Concourse

This is the compilation of proposed [docker-compose solution](https://concourse.ci/docker-repository.html) and my own experience.

### Prerequisites

- virtualbox
- bash
- docker-machine binary
- docker-compose binary
- docker binary

### How to start

1. `certs.sh`
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
1. `compose.sh` - execute docker compose command in docker machine context
