#!/bin/bash

MYDIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"

PKGLIST="$(find . -name PKGBUILD)"

if [[ -z "${PKGLIST}" ]] ; then
    echo -e "No PKGBUILD files found!"
    if [[ "$0" = "$BASH_SOURCE" ]] ; then
        exit 2
    else
        return 2
    fi
fi

echo -e "AUR Packages found:\n${PKGLIST}"

read -p "Do you want to upgrade? [Y/n] " -r
REPLY="${REPLY:-y}"
if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    if [[ "$0" = "$BASH_SOURCE" ]] ; then
        exit 1
    else
        return 1
    fi
fi

for pkg in ${PKGLIST} ; do
    dir="$(dirname ${pkg})"
    cd "${dir}"
    #echo "${dir}"
    cd - 2>&1 > /dev/null
done

