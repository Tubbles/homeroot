#!/usr/bin/env bash

my_dir="$(dirname "$(realpath "${0}")")"

usage() {
    echo "usage: ${0} <theme name in ${my_dir}>"
}

theme="${my_dir}/${1}.kdl"

if [[ ! -r "${theme}" ]]; then
    usage
    exit 1
fi

active="${my_dir}/active.kdl"
zellij_config_dir="$(dirname "${my_dir}")"

sed '2c\    active {' "${theme}" >"${active}"
touch "${zellij_config_dir}/config.kdl" # refresh
