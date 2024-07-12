#!/bin/bash

if [ -f "./container.conf" ]; then
    source ./container.conf
else
    echo ""
    echo "Configuration not found. Exiting."
    echo ""
    exit 1
fi

SETUP() {
    if [ ! -f "/usr/share/keyrings/raspberrypi-archive-keyring.gpg" ]; then
        wget http://archive.raspberrypi.com/debian/pool/main/r/raspberrypi-archive-keyring/raspberrypi-archive-keyring_2021.1.1+rpt1_all.deb
        sudo dpkg -i ./raspberrypi-archive-keyring_2021.1.1+rpt1_all.deb
    fi
}

BOOTSTRAP() {
case "$1" in
    rpi)
        sudo debootstrap --arch=$ARCH --components=main,contrib,non-free,rpi --include=wget,bash-completion \
            --keyring=/usr/share/keyrings/raspberrypi-archive-keyring.gpg bullseye build/ http://archive.raspberrypi.com/debian/
    ;;
    *)
        sudo debootstrap --arch=$ARCH --variant=$VARIANT --components=main,contrib,non-free \
            --include=wget,bash-completion,sudo,ca-certificates,findutils,gnupg,dirmngr,inetutils-ping,netbase,curl,udev,procps \
            $RELEASE build/ http://deb.debian.org/debian/ \
            && cd build \
            && sudo tar --numeric-owner -czvf ../rpios-stable-rootfs-$ARCH.tar.gz ./* \
            && cd .. \
            && sudo rm -rf build
    ;;
esac
}

IMG() {
podman build --squash -t $REGISTRY$IMAGE:$ARCH-latest -f ./Containerfile.$ARCH
}

CHECK() {
if [ -f "./rpios-stable-rootfs-$ARCH.tar.gz" ]; then
    echo ""
    read -e -p "Existing rootfs found.. Delete and recreate [Y/N]: " -i "N" REBOOTSTRAP
    if [[ "$REBOOTSTRAP" == [yY] ]]; then
        BOOTSTRAP
    fi
else
    BOOTSTRAP
fi
}

case "$1" in
    armhf)
        ARCH=armhf
        SETUP
        CHECK
        IMG
    ;;
    arm64)
        ARCH=arm64
        SETUP
        CHECK
        IMG
    ;;
    *)
        echo ""
        echo "Usage: $(basename $0) {armhf|arm64}"
        echo ""
        exit 1
    ;;
esac
