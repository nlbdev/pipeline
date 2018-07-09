#!/usr/bin/env bash
[[ -n ${VERBOSE+x} ]] && set -x
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
for arg in "$@"; do
    cd "$DIR/$arg"
    eval $GRADLE install
done
