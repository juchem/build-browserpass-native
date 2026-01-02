A self-contained, sandboxed container image that will build and install
[browserpass_native](https://github.com/browserpass/browserpass-native).

**TL;DR**: build and install latest version under `/usr/local`:
```
# build the builder image:
make image

# build latest `browserpass_native` using the builder image:
make

# start build environment using the builder image:
# once inside the build environment, run `/srv/entrypoint.sh`
# to build `browserpass_native`
make interactive
```

The source code for this image can be found at
[juchem/build-browserpass_native](https://github.com/juchem/build-browserpass_native).

Choose the version to build by setting environment variables (defaults to
`HEAD` for bleeding edge):
- [`BROWSERPASS_NATIVE_VERSION`](https://github.com/browserpass/browserpass-native/tags)

Binaries will be installed into the container's directory `/out`. Mount that
directory with `-v host_dir:/out` to install it into some host directory.

Customize the base installation directory by setting the environment variable
`PREFIX_DIR`. Defaults to `/usr/local`.

Example: build given version and install under `~/opt` (remove
`--runtime=/usr/bin/crun` to use default container runtime):
```
OUT_DIR="$HOME/opt"
mkdir -p "${OUT_DIR}"
# build browserpass_native using the build image
podman run -it --rm \
  --runtime=/usr/bin/crun \
  -v "${OUT_DIR}:/out" \
  -e "BROWSERPASS_NATIVE_VERSION=v1.2.3" \
  build-browserpass_native
```
