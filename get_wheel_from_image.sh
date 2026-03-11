#!/bin/bash

#docker run --rm -v $(pwd)/wheels:/dist_container mediapipe-aarch64 cp -r /wheelhouse/. /dist_container
#docker run --rm -v $(pwd)/wheels:/dist_container mediapipe-aarch64 bash -c "cp -r /mediapipe/wheelhouse/. /dist_container && chown -R $(id -u):$(id -g) /dist_container"
docker run --rm -v $(pwd)/wheels:/dist_container mediapipe-aarch64 bash -c "cp -r /wheelhouse/. /dist_container && chown -R $(id -u):$(id -g) /dist_container"

exit 0

