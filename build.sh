#!/bin/bash
set -eu -o pipefail
img=$1
mkdir catalog
./convert.sh veneer.yaml > catalog/catalog.yaml
opm validate catalog
opm alpha generate dockerfile catalog
docker build -t $img -f catalog.Dockerfile .
docker push $img
rm -r catalog catalog.Dockerfile
