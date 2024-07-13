#!/bin/bash

IMAGE=${PWD##*/}
REGISTRY=ghcr.io/nakarma/containers/
TEMP=/data/temp/builds

BUILD() {
    TMPDIR=$TEMP podman build -t $REGISTRY$IMAGE:$ARCH-latest -f $1
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
