#!/usr/bin/env bash

if ! [ -x "$(command -v docker-machine)" ]; then
  echo 'Error: docker-machine is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters. Pass compose file"
    exit
fi

if [[ ! -f "$1" ]]; then
    echo "Compose file was not found"
    exit
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

docker-compose -f "$1" down "${@:2}"