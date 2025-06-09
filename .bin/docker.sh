#!/usr/bin/env bash

# Set up sane bash failure flags
set -euo pipefail

usage="$(basename "$0") - Docker helper facilitating running a dev/ci container in a reproducible manner
Usage:
    $(basename "$0") [--local] [<argument>] [<command>]
, where

[--local]   Use the locally built image when running commands

<argument> can be zero or one of:
    [help|--help|-h [full]]     Show this help text and exit, optionally with extra configuration details
    login                       Log in to the container registry to be able to pull the image
    [update|pull]               Pull the latest image
    build                       Build the image locally
    test                        Run this script's unit tests

If an <argument> is given, any <command>s also given will be forwarded to the respective docker command as arguments. If
no <argument> is given, a container will be temporarily instantiated and the <command>s will be executed inside it. If
neither an <argument> nor a <command> is given, a container will be temporarily instantiated and interactively logged
into.

If the image does not exist in the local registry, it will be fetched from the remote registry. This might require a
login operation first, available through the login <argument>. Alternatively, it can also be built using the build
<argument>, in which case any subsequent <command>s must be executed with the [--local] flag."

details="DETAILS:
The script automatically mounts and makes available in the container: 1) its own directory (where it is located), 2) the
caller's current working directory, 3) the docker_home directory, and optionally 4) a directory specified in the
'workspace_dir' variable. These directories will have the same paths inside the container, owner and permission flags as
in the host environment. Furthermore, the current user id and group id of the running process inside the container will
be mirrored from that of the caller.

The script automatically uses podman as the runner if that is installed, otherwise it falls back to docker.

CONFIGURATION:
The script fetches environment variables, local variables and arrays from files called .dockerenv, which it searches for
and sources from three different locations in the order: 1) same directory as where this script is located, 2) the
caller's current working directory, and 3) the caller's home directory. The search will also recursively search all
parent directories all the way up to the filesystem root. If several matches are found they are all sourced in order, so
files found later can potentially override configurations from earlier files.

Possible configuration:
* extra_pull_flags          bash array containing extra flags to be given to pull operations
* extra_build_flags         bash array containing extra flags to be given to build operations
* extra_run_flags           bash array containing extra flags to be given to run operations
* workspace_dir             + Optional extra directory to mount
* image_name                + The name of the image, defaults to ubuntu
* image_tag                 + The image tag to use, defaults to latest
* image                     + Full identifier of the image to use, defaults to <image_name>:<image_tag>
* registry                  + The remote registry to use, defaults to docker.io
* full_url                  + Full url of the image, defaults to <registry>/<image>
* local_directory           + The local directory where a Dockerfile is located, for local builds, defaults to
                              <script directory>/docker
* docker_home               + The home directory to use inside the container, defaults to <script directory>/.docker_home
* driver                    + The driver to use, defaults to podman if installed, otherwise docker

All configuration defaults are available with the _default prefix. Configurations marked with a '+' are environment
variables and can be overriden on the bash command line by prefixing the script invoaction, ie var=val <script>.

EXAMPLES:
To eg. build some project:
    $(basename "$0") make clean all
To eg. use a specific tag (in bash):
    image_tag=my-tag $(basename "$0") make clean all"

my_dir="$(dirname "$(realpath "$0")")"
current_dir="$(pwd)"

# Run a command after echoing it to stdout
trace-run() {
    (
        set -x
        "$@"
    )
}

test_functions=()

source "${my_dir}/docker-conf.sh"

pull_flags=()
build_flags=()
run_flags=()
extra_pull_flags=()
extra_build_flags=()
extra_run_flags=()

: "${image_name:="ubuntu"}"
: "${image_tag:="latest"}"
: "${registry:="docker.io"}"
: "${local_directory:="${my_dir}/docker"}"
: "${workspace_dir:="${current_dir}"}"
: "${docker_home:="${my_dir}/.docker_home"}"

# Load environment variables from .dockerenv files
# This would give HOME highest priority
load_conf_files ".dockerenv" "${HOME}" "${current_dir}" "${my_dir}"

# Set up variables
: "${image:="${image_name}:${image_tag}"}"
: "${full_url:="${registry}/${image}"}"

# If ${driver} is unset or empty, auto-detect podman or docker
if [[ -z "${driver:-}" ]]; then
    if command -v podman &>/dev/null; then
        # Default to podman
        driver=podman
    else
        driver=docker
    fi
fi

if [[ "${driver}" == "podman" ]]; then
    # The userns trick does not work in docker
    run_flags+=(--userns keep-id) # Set up the container user
    build_flags=(--format docker)
fi

if [[ "$(uname)" == "Darwin" ]]; then
    # userns is not needed for macos, since we are already running in a "linux vm" that takes care of all user
    # permission related stuff https://github.com/databio/bulker/issues/30
    pull_flags+=("--platform linux/amd64")
    build_flags+=("--platform linux/amd64")
    run_flags+=("--platform linux/amd64")
else
    run_flags+=(--user "$(id -u):$(id -g)") # Set up the container user
fi

case "${1:-}" in
"help" | "--help" | "-h")
    shift
    echo "${usage}"

    if [[ "${1:-}" == "full" ]]; then
        echo -e "\n${details}"
    fi
    ;;
"login")
    shift
    trace-run "${driver}" login "${registry}" "$@"
    ;;
"update" | "pull")
    shift
    # don't let pull_flags variable expansion produce an empty string if empty
    # shellcheck disable=SC2068
    trace-run "${driver}" pull \
        ${pull_flags[@]} \
        ${extra_pull_flags[@]} \
        "${full_url}" \
        "$@"
    ;;
"build")
    shift

    if [[ -r "${my_dir}/ghtoken" ]]; then
        build_flags+=("--secret id=GH_TOKEN,src=${my_dir}/ghtoken")
    fi

    # Don't let build_flags variable expansion produce an empty string if empty
    # shellcheck disable=SC2068
    trace-run "${driver}" build \
        ${build_flags[@]} \
        -t "${image}" \
        ${extra_build_flags[@]} \
        "${local_directory}" \
        "$@"
    ;;
"test")
    # Run all test_functions
    for test_function in "${test_functions[@]}"; do
        if ! "${test_function}"; then
            echo "Test '${test_function}' failed"
            exit 1
        fi
    done

    echo "All tests passed"
    ;;
*)
    mkdir -p "${docker_home}"

    if [[ "${1:-}" == "--local" ]]; then
        shift
        full_url="${image}"
    fi

    # Detect if we are in an interactive terminal
    if [[ -t 1 ]]; then
        run_flags+=(--interactive --tty)
    fi

    # Set up the mounts
    declare -A mount_paths=() # Use associative array to track unique paths

    # Add all potential mount paths, duplicates will be automatically eliminated
    mount_paths["${current_dir}"]=1
    mount_paths["${my_dir}"]=1
    mount_paths["${workspace_dir}"]=1
    mount_paths["${docker_home}"]=1

    # Add volume mount for each unique path
    for dir in "${!mount_paths[@]}"; do
        run_flags+=(--volume "${dir}:${dir}")
    done

    # don't let run_flags variable expansion produce an empty string if empty
    # shellcheck disable=SC2068
    trace-run "${driver}" run \
        ${run_flags[@]} \
        --rm \
        --env "HOME=${docker_home}" \
        --workdir "${current_dir}" \
        ${extra_run_flags[@]} \
        "${full_url}" \
        "$@"
    ;;
esac
