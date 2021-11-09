#!/bin/bash

BASE_DIR="/home/flightgear"

mkdir output
docker run \
 --rm \
 --mount "type=bind,source=`pwd`/data,target=${BASE_DIR}/data,readonly" \
 --mount "type=bind,source=`pwd`/output,target=${BASE_DIR}/output" \
 flightgear/ws30-vbp-generator:v1