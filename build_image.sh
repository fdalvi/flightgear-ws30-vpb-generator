#!/bin/bash

# Clone fgmeta
mkdir -p build
cd build
if [ -d "fgmeta" ]; then
	cd fgmeta
	git pull origin next
	cd ..
else
	git clone --branch next https://git.code.sf.net/p/flightgear/fgmeta fgmeta
fi
cd ..

# Build docker image
docker build . -t flightgear/ws30-vbp-generator:v1.1