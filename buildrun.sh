#!/bin/sh
set -e

IMAGE=sysbench
docker build -t "${IMAGE}" .
docker run -it --rm -u $(id -u):$(id -g) "${IMAGE}"
