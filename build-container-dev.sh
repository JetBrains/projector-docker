#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution


cd ../projector-core

./gradlew :projector-client-web:browserProductionWebpack
./gradlew :projector-server:distZip
./gradlew :projector-plugin-markdown:buildPlugin

cd -

containerName=${1:-projector-idea-c}
downloadUrl=${2:-https://download.jetbrains.com/idea/ideaIC-2019.3.4.tar.gz}

# build container:
DOCKER_BUILDKIT=1 docker build --progress=plain -t "$containerName" --build-arg buildGradle=false --build-arg "downloadUrl=$downloadUrl" -f Dockerfile ..
