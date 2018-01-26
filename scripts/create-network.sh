#!/usr/bin/env bash

if ! [ -x "$(command -v docker-machine)" ]; then
  echo 'Error: docker-machine is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

if [[ ! -f "./env.config" ]]; then
    echo "Config file not found. Run this script from project root folder"
    exit
fi

source ./env.config

IS_RUN=$(docker-machine ls --filter "name=${ENV_NAME}" --filter "state=Running" -q)
if [[ -z "${IS_RUN}" ]]; then
  echo "- Machine does not exists $?"
  exit
fi

eval "$(docker-machine env "${ENV_NAME}")"

IS_RUN=$(docker network ls --filter "name=${ENV_NETWORK}" -q)
if [[ -n "${IS_RUN}" ]]; then
  echo "- Such network already exists"
  exit
fi

docker network create "${ENV_NETWORK}"