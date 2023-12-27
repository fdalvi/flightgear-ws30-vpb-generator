#!/bin/bash

BASE_DIR="/home/flightgear"

mkdir -p output
docker run \
 --rm \
 --mount "type=bind,source=`pwd`/data,target=${BASE_DIR}/data,readonly" \
 --mount "type=bind,source=`pwd`/output,target=${BASE_DIR}/output" \
 -it \
 flightgear/ws30-vpb-generator:v1.5 /bin/bash $1
