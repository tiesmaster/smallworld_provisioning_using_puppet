#!/bin/bash

BUILD_TARGET=$1

CAMBRIDGE_PRODUCT=/opt/smallworld/cambridge_db
export SW_WHICH_GIS_ALIAS_FILE=${CAMBRIDGE_PRODUCT}/config/magik_images/resources/base/data/gis_aliases
export LOG_DIR=/dev

BASE_DIR=$(dirname $0)
BUILD_DIR=${BASE_DIR}/build

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

(until killall fgrep
do
  sleep 1
done) >/dev/null 2>&1 &

gis $BUILD_TARGET stdout
