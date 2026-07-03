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

PREFIX ?= /usr/local

BROWSERPASS_EXE ?= $(PREFIX)/bin/browserpass

CHROMIUM_DST_DIR ?= /etc/chromium/native-messaging-hosts
FIREFOX_DST_DIR ?= /usr/lib/mozilla/native-messaging-hosts
BRAVE_DST_DIR ?= /etc/opt/chrome/native-messaging-hosts

HOSTS_JSON ?= com.github.browserpass.native.json

HOSTS_SRC_DIR ?= $(PREFIX)/lib/browserpass/hosts

CHROMIUM_SRC_DIR ?= $(HOSTS_SRC_DIR)/chromium
FIREFOX_SRC_DIR ?=	$(HOSTS_SRC_DIR)/firefox
BRAVE_SRC_DIR ?=		$(CHROMIUM_SRC_DIR)

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

.PHONY: install
install:
	mkdir -p "$(PREFIX)"
	rsync -av "$(BUILD_DIR)/" "$(PREFIX)"
	find "$(HOSTS_SRC_DIR)" \
		-name $(HOSTS_JSON) \
		-exec sed -i -e 's|%%replace%%|$(BROWSERPASS_EXE)|g' '{}' +
	#rm -rf "$(BUILD_DIR)"

.PHONY: install-chromium
install-chromium: install
	mkdir -p "$(CHROMIUM_DST_DIR)"
	ln -sfv "$(CHROMIUM_SRC_DIR)/$(HOSTS_JSON)" "$(CHROMIUM_DST_DIR)/$(HOSTS_JSON)"

.PHONY: install-firefox
install-firefox: install
	mkdir -p "$(FIREFOX_DST_DIR)"
	ln -sfv "$(FIREFOX_SRC_DIR)/$(HOSTS_JSON)" "$(FIREFOX_DST_DIR)/$(HOSTS_JSON)"

.PHONY: install-brave
install-brave: install
	mkdir -p "$(BRAVE_DST_DIR)"
	ln -sfv "$(BRAVE_SRC_DIR)/$(HOSTS_JSON)" "$(BRAVE_DST_DIR)/$(HOSTS_JSON)"

.PHONY: build
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
