#!/bin/bash

BUILD_TARGET=$1

CAMBRIDGE_PRODUCT=/opt/smallworld/cambridge_db
export SW_WHICH_GIS_ALIAS_FILE=${CAMBRIDGE_PRODUCT}/config/magik_images/resources/base/data/gis_aliases

BASE_DIR=$(dirname $0)
BUILD_DIR=${BASE_DIR}/build

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

gis $BUILD_TARGET
