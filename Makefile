.PHONY: all image build interactive

BUILD_DIR ?= /tmp/build-browserpass_native/out
INSTALL_DIR ?= /usr/lib/browserpass

CONTAINER_RUNTIME ?= /usr/bin/crun

all: build

image:
	podman build \
		--runtime="$(CONTAINER_RUNTIME)" \
		-t build-browserpass_native \
		-f Containerfile \
			container

image-from-scratch:
	podman build \
		--runtime="$(CONTAINER_RUNTIME)" \
		-t build-browserpass_native \
		--no-cache \
		-f Containerfile \
			container

build-from-scratch: image-from-scratch
	mkdir -p "$(BUILD_DIR)"
	podman run -it --rm \
		--runtime="$(CONTAINER_RUNTIME)" \
		-v "$(BUILD_DIR):/out" \
		--env-file .env \
			build-browserpass_native

interactive-from-scratch: image-from-scratch
	mkdir -p "$(BUILD_DIR)"
	podman run -it --rm \
		--runtime="$(CONTAINER_RUNTIME)" \
		-v "$(BUILD_DIR):/out" \
		--env-file .env \
		--entrypoint bash \
			build-browserpass_native

build: image
	mkdir -p "$(BUILD_DIR)"
	podman run -it --rm \
		--runtime="$(CONTAINER_RUNTIME)" \
		-v "$(BUILD_DIR):/out" \
		--env-file .env \
			build-browserpass_native

interactive: image
	mkdir -p "$(BUILD_DIR)"
	podman run -it --rm \
		--runtime="$(CONTAINER_RUNTIME)" \
		-v "$(BUILD_DIR):/out" \
		--env-file .env \
		--entrypoint bash \
			build-browserpass_native

install: build
	sudo mv \
		"$(BUILD_DIR)/browserpass-linux64" \
		"$(INSTALL_DIR)/browserpass-native"

help:
	grep '^[a-zA-Z\-_0-9].*:' Makefile | cut -d : -f 1 | sort
