#!/bin/bash
#
# Shell script to build a Golang builder image using Buildah.
# This script should be run within a buildah unshare session.
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print usage and exit
usage() {
    echo "Usage: buildah unshare ./mk-builder.sh <image name:tag>"
    echo "Example: buildah unshare ./mk-builder.sh quay.io/username/go-builder:1.23.4"
    exit 1
}

# Check if an image name is provided
if [ -z "$1" ]; then
    usage
fi

IMAGE_NAME="$1"

echo "Building golang buildah image: $IMAGE_NAME"

export GO_VERSION=1.23.4
export GO_FILE=go${GO_VERSION}.linux-amd64.tar.gz
export GOLANG_URL=https://go.dev/dl/${GO_FILE}
echo $GOLANG_URL

container=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal:latest)
mnt=$(buildah mount $container)

# Ensure /usr/local exists
mkdir -p $mnt/usr/local

# Download and install golang
wget $GOLANG_URL -O $mnt/tmp/$GO_FILE && \
rm -rf $mnt/usr/local/go && \
tar -C $mnt/usr/local -xzf $mnt/tmp/$GO_FILE && \
rm $mnt/tmp/$GO_FILE

echo "PATH=\$PATH:/usr/local/go/bin" >> $mnt/root/.bashrc

# Commit the container to create the image with the provided image name
buildah commit --format docker "$container" "$IMAGE_NAME"

# Unmount the container
buildah unmount "$container"

echo "Golang builder image '$IMAGE_NAME' created successfully."
