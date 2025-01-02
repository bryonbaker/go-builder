#!/bin/bash
#
# Shell script to build a Golang builder image using Buildah.
# This script should be run within a buildah unshare session.
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print usage and exit
usage() {
    echo "Usage: buildah unshare ./mk-builder.sh <golang release filename> <golang release url> <image name:tag>"
    echo "Example: buildah unshare ./mk-builder.sh go1.23.4.linux-amd64.tar.gz https://go.dev/dl/go1.23.4.linux-amd64.tar.gz quay.io/username/go-builder:1.23.4"
    exit 1
}

# Check if an image name is provided
if [ -z "$1" ]; then
    usage
fi

GO_FILE="$1"
GOLANG_URL="$2"
IMAGE_NAME="$3"

echo "Building golang buildah image: $IMAGE_NAME"
echo "Golang release: $GOLANG_URL"

container=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal:latest)
mnt=$(buildah mount $container)

# Ensure /usr/local exists
mkdir -p $mnt/usr/local

# Download and install golang
wget $GOLANG_URL -O $mnt/tmp/$GO_FILE && \
rm -rf $mnt/usr/local/go && \
tar -C $mnt/usr/local -xzf $mnt/tmp/$GO_FILE && \
rm $mnt/tmp/$GO_FILE

# echo "PATH=\$PATH:/usr/local/go/bin" >> $mnt/root/.bashrc

# Set Go environment variables
echo "Setting environment variables..."
buildah config --env PATH=/usr/local/go/bin:$PATH $container
buildah config --env GOROOT=/usr/local/go $container
buildah config --env GOPATH=/root/go $container
buildah config --env PATH=/root/go/bin:/usr/local/go/bin:$PATH $container

# (Optional) Create GOPATH directory
mkdir -p $mnt/root/go

# Commit the container to create the image with the provided image name
buildah commit --format docker "$container" "$IMAGE_NAME"

# Unmount the container
buildah unmount "$container"

echo "Golang builder image '$IMAGE_NAME' created successfully."
