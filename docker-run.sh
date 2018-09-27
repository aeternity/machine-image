#/bin/bash

DOCKER_IMAGE=${DOCKER_IMAGE:-aeternity/infrastructure}

docker run --rm -it --env-file env.list -w /root/ \
    -v ${PWD}/packer:/root/packer \
    $DOCKER_IMAGE "$@"
