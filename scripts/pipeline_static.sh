#!/bin/bash

set -e

fly --target tutorial login --concourse-url "http://$(docker-machine ip concourse):8080" -b
fly --target tutorial sync
fly --target tutorial set-pipeline -c fly/pipeline_static.yml -p helloworld -n
fly --target tutorial unpause-pipeline -p helloworld
fly --target tutorial unpause-job --job helloworld/hello-world
fly --target tutorial trigger-job --job helloworld/hello-world -w
