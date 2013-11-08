#!/bin/bash

vagrant destroy -f && vagrant up && scripts/invoke-test.sh
