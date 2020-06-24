#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

TEMPFILE="`tempfile`"
docker build . | tee $TEMPFILE
BUILD_ID="`cat $TEMPFILE | tail -n 1 | awk '{print $3}'`"
echo "BUILD_ID: $BUILD_ID"
RM="--rm"
IT="-it"

set -x
docker run \
  $RM $IT \
  --network host \
  --env-file config.env \
  "$@" \
  "$BUILD_ID"
