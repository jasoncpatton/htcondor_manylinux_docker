#!/bin/bash
set -ex

DOCKERFILE_DIR=$(dirname "$(readlink -f "$0")")/docker/
DOCKER_REPO=dockerreg.chtc.wisc.edu
TAG="htcondor_manylinux1_x86_64:$(head -n 1 latest_tag)"

docker build $DOCKERFILE_DIR -t $TAG
docker tag $TAG $DOCKER_REPO/htcondor/$TAG
docker push $DOCKER_REPO/htcondor/$TAG
