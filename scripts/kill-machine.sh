#!/usr/bin/env bash

if ! [ -x "$(command -v docker-machine)" ]; then
  echo 'Error: docker-machine is not installed.' >&2
  exit 1
fi

if [[ ! -f "./env.config" ]]; then
    echo "Config file not found. Run this script from project root folder"
    exit
fi

source ./env.config

IS_RUN=$(docker-machine ls --filter "name=${ENV_NAME}" --filter "state=Running" -q)
if [[ -n "${IS_RUN}" ]]; then
  echo -n "- Machine already exists. Continue with deletion? (y/n): "
  read -r CONFIRMATION
  if [[ "${CONFIRMATION}" != "y" ]] && [[ "${CONFIRMATION}" != "Y" ]]; then
    echo "- Aborted"
    exit
  fi
else
  echo "- Nothing to delete"
  exit
fi

docker-machine stop "${ENV_NAME}"
docker-machine rm "${ENV_NAME}" -f -y
