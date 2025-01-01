#!/bin/bash
#
# Run this shell script after you have run the command: "buildah unshare"
#
echo "Building golang buildah image."
echo "Run buildah unshare before you run this script"

export GO_VERSION=1.23.4
export GO_FILE=go${GO_VERSION}.linux-amd64.tar.gz
export GOLANG_URL=https://go.dev/dl/${GO_FILE}
echo $GOLANG_URL

container=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal:latest)
mnt=$(buildah mount $container)
# Download and install golang
wget $GOLANG_URL -O $mnt/tmp/$GO_FILE && \
rm -rf $mnt/usr/local/go && \
tar -C $mnt/usr/local -xzf $mnt/tmp/$GO_FILE && \
rm $mnt/tmp/$GO_FILE

echo "PATH=\$PATH:/usr/local/go/bin" >> $mnt/root/.bashrc

buildah commit --format docker $container go-builder:$GO_VERSION