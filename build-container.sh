#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

# create dir for transfrering projector files (if projector-core is a symlink, it won't be added to the build context):
PROJECTOR_CORE_COPY=projector-core-copy
rm -rf $PROJECTOR_CORE_COPY
mkdir $PROJECTOR_CORE_COPY
cp -r projector-core/* $PROJECTOR_CORE_COPY

# build container:
sudo docker build -t projector-image --build-arg buildGradle=true .
