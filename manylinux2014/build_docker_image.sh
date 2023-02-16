#!/bin/bash
set -ex

DOCKERFILE_DIR=$(dirname "$(readlink -f "$0")")/docker/
TAG="htcondor_manylinux2014_x86_64:$(head -n 1 latest_tag)"

docker pull quay.io/pypa/manylinux2014_x86_64
docker build $DOCKERFILE_DIR -t $TAG
docker tag $TAG htcondor/$TAG
docker push htcondor/$TAG
