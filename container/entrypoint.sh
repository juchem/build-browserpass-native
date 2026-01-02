#!/bin/bash -xe

build_browserpass_native() {
  pushd "${BROWSERPASS_NATIVE_SRC}" > /dev/null

  build_version="${BROWSERPASS_NATIVE_VERSION}"
  [ -n "${build_version}" ] || build_version="HEAD"
  git fetch --depth=1 origin "${build_version}"
  git checkout -b "build-${build_version}-$(date +%s)" FETCH_HEAD
  git clean -xfd
  git submodule update --init --recursive --depth=1

  (set -x; \
    make browserpass-linux64 \
    && strip --strip-all browserpass-linux64 \
    && mv browserpass-linux64 "${OUT_DIR}/" \
  )

  popd > /dev/null
}

(set -x; apt-get update)
(set -x; apt-get upgrade -y --only-upgrade --no-install-recommends)

(set -x; build_browserpass_native "$@")

cat <<EOF

Successfully built browserpass_native.

Move /tmp/build-browserpass_native/out/browserpass-linux64 to /usr/lib/browserpass/browserpass-native:
\`\`\`
mv /tmp/build-browserpass_native/out/browserpass-linux64 /usr/lib/browserpass/browserpass-native
\`\`\`
EOF
