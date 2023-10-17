#!/usr/bin/env bash

podman run \
    --rm \
    --interactive \
    --tty \
    --userns keep-id \
    --volume "$(pwd)":"$(pwd)" \
    --workdir "$(pwd)" \
    deck \
    "$@"
