#!/bin/bash

SCRIPT_NAME=$1
SCRIPTS_DIR=/vagrant/scripts
SCRIPT_FILE=${SCRIPTS_DIR}/${SCRIPT_NAME}

vagrant ssh -c $SCRIPT_FILE -- -X
