# Makefile for building shakeout-app container

GO_VERSION := 1.23.4
GO_FILE := go$(GO_VERSION).linux-amd64.tar.gz
GOLANG_URL := https://go.dev/dl/$(GO_FILE)
IMAGE_NAME := quay.io/bryonbaker/go-builder
TAG := $(GO_VERSION)

.PHONY: all build push clean

all: build push

build:
	buildah unshare ./mk-builder.sh $(GO_FILE) $(GOLANG_URL) $(IMAGE_NAME):$(TAG)

push:
	podman push $(IMAGE_NAME):$(TAG)

clean:
	podman rmi -f $(IMAGE_NAME):$(TAG) || true
