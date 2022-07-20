#!/bin/bash
set -ex

DOCKERFILE_DIR=$(dirname "$(readlink -f "$0")")/docker/
TAG="htcondor_manylinux2014_x86_64:$(head -n 1 latest_tag)"

docker build $DOCKERFILE_DIR -t $TAG
docker tag htcondor/$TAG
docker push htcondor/$TAG
