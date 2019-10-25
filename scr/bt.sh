#!/bin/bash

if (( $# < 2 )) ; then
    echo -e "usage: $0 <device> <command>"
    echo -e "usage: $0 <command>"
    exit 1
fi

case $1 in
ssa3)
    device="28:9A:4B:20:07:16"
    ;;
*)
    echo -e "Unknown device; $1"
    exit 2
    ;;
esac

if [[ $2 ]] ; then

