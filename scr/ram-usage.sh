#!/usr/bin/env bash

output=""
for app in "$@" ; do output+="$(echo -n "$app " ; ps -eo pmem,command --sort -pcpu | grep $app | awk '{p=$1 ; sum +=p} END {print sum}')\n" ; done
printf "$output" | sort -k2 -hr
