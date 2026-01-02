# TODO: import `build.args`
IMAGE_NAME=build-browserpass-native
IMAGE_TAG=latest

# squash-all, squash, layers
BUILD_MODE ?= squash-all
# newer, missing, always, never
PULL_POLICY ?= newer
NO_CACHE=false

BUILD_DIR ?= /tmp/$(IMAGE_NAME)
SRC_DIR=container

CONTAINER_RUNTIME ?= /usr/bin/crun


INSTALL_DIR ?= /usr/local/lib/browserpass

.PHONY: all
all: build

.PHONY: image
image:
	podman build \
		--runtime="$(CONTAINER_RUNTIME)" \
		--$(BUILD_MODE) \
		--pull="$(PULL_POLICY)" \
		--no-cache="$(NO_CACHE)" \
		--build-arg-file="build.args" \
		--tag "$(IMAGE_NAME):$(IMAGE_TAG)" \
			"$(SRC_DIR)"

install: build
	sudo mkdir -p "$(INSTALL_DIR)"
	sudo mv \
		"$(BUILD_DIR)/browserpass-linux64" \
		"$(INSTALL_DIR)/browserpass-native"

.PHONY: image
build: image
	mkdir -p "$(BUILD_DIR)"
	podman run \
		--runtime="$(CONTAINER_RUNTIME)" \
		-it --rm \
		--env-file .env \
		-v "$(BUILD_DIR):/out" \
			"$(IMAGE_NAME):$(IMAGE_TAG)"
	echo "install with \`dpkg -i '$(BUILD_DIR)/*.deb'\`"

.PHONY: interactive
interactive: image
	mkdir -p "$(BUILD_DIR)"
	podman run \
		--runtime="$(CONTAINER_RUNTIME)" \
		-it --rm \
		--env-file .env \
		-v "$(BUILD_DIR):/out" \
		--entrypoint bash \
			"$(IMAGE_NAME):$(IMAGE_TAG)"

.PHONY: help
help:
	@grep '^[a-zA-Z\-_0-9].*:' Makefile | cut -d : -f 1 | sort
