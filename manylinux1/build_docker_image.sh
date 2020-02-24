#!/bin/bash
set -ex

DOCKERFILE_DIR=$(dirname "$(readlink -f "$0")")/docker/
DOCKER_REPO=dockerreg.chtc.wisc.edu
TAG=$(head -n 1 latest_tag)

docker build $DOCKERFILE_DIR -t htcondor_manylinux1_x86_64:$TAG
docker push $DOCKER_REPO/htcondor/htcondor_manylinux1:$TAG
