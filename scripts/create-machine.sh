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
  echo "- Machine already exists $?"
  exit
fi

docker-machine create -d "virtualbox" "${ENV_NAME}"
MACHINE_IP=$(docker-machine ip "${ENV_NAME}")

echo ""
echo "Docker machine is ready"
echo "---------------------------------------------------"
echo "Please set the following variable in env.config to:"
echo "export ENV_CONCOURSE_URL=http://${MACHINE_IP}:8080 "
echo "---------------------------------------------------"
echo ""