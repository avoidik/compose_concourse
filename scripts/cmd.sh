#!/usr/bin/env bash

if ! [ -x "$(command -v docker-machine)" ]; then
  echo 'Error: docker-machine is not installed.' >&2
  exit 1
fi

if [ "$#" -eq 0 ]; then
    echo "Illegal number of parameters. Specify at least one"
    exit
fi

if [[ ! -f "./env.config" ]]; then
    echo "Config file not found. Run this script from project root folder"
    exit
fi

source ./env.config

IS_RUN=$(docker-machine ls --filter "name=${ENV_NAME}" --filter "state=Running" -q)
if [[ -z "${IS_RUN}" ]]; then
  echo "- Machine does not exists"
  exit
fi

eval "$(docker-machine env "${ENV_NAME}")"

exec "$@"