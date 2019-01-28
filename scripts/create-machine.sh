#!/usr/bin/env bash

BOOT_URL="https://github.com/boot2docker/boot2docker/releases/download/v18.06.1-ce/boot2docker.iso"

if ! [ -x "$(command -v docker-machine)" ]; then
  echo 'Error: docker-machine is not installed.' >&2
  exit 1
fi

if [[ ! -f "./env.config" ]]; then
  echo "Config file not found. Run this script from project root folder"
  exit
fi

if [[ ! -f "./keys/web/tsa_host_key" ]] || [[ ! -f "./keys/worker/worker_key" ]]; then
  echo "Certificates were not found. Please generate them with scripts/certs.sh before"
  exit
fi

source ./env.config

IS_RUN=$(docker-machine ls --filter "name=${ENV_NAME}" --filter "state=Running" -q)
if [[ -n "${IS_RUN}" ]]; then
  echo "- Machine already exists $?"
  exit
fi

docker-machine create --driver "virtualbox" --virtualbox-boot2docker-url "$BOOT_URL" "${ENV_NAME}"

echo ""
echo "Docker machine is ready"
echo ""
