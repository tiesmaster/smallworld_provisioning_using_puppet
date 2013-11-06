#!/bin/bash

SCRIPT_NAME=$1
BUILD_SCRIPTS_DIR=/vagrant/scripts
BUILD_SCRIPT=${BUILD_SCRIPTS_DIR}/${SCRIPT_NAME}

vagrant ssh -c $BUILD_SCRIPT -- -X
