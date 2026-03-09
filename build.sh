#!/bin/bash

DOCKER_BUILDKIT=1 docker build -f Dockerfile.manylinux_2_28_aarch64 -t mediapipe-aarch64 . --build-arg "PYTHON_BIN=/opt/python/cp312-cp312/bin/python3.12" --progress=plain

exit $?

