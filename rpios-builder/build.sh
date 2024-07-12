#!/bin/bash

IMAGE=${PWD##*/}
REGISTRY=ghcr.io/nakarma/containers/

BUILD() {
    podman build -t $REGISTRY$IMAGE:$ARCH-latest -f $1
}

case "$1" in
    armhf)
        ARCH=armhf
        BUILD ./Containerfile.armhf
    ;;
    arm64)
        ARCH=arm64
        BUILD ./Containerfile.arm64
    ;;
    *)
        echo ""
        echo "Usage: $(basename $0) {armhf|arm64}"
        echo ""
    ;;
esac
