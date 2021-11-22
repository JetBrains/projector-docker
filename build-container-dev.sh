#!/bin/sh

#
# Copyright 2019-2020 JetBrains s.r.o.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

containerName=${1:-projector-idea-c}
downloadUrl=${2:-https://download.jetbrains.com/idea/ideaIC-2019.3.5.tar.gz}
localGradlePath=${3:-../projector-server}

# Cleanup old files except .gitkeep
find ./build-tools/projector-server ! -name '.gitkeep' -type f -exec rm -f {} +
# Copy files from external projector-server folder
cp "$localGradlePath" ./build-tools/projector-server
cd ./build-tools/projector-server
# Build projector-server
./gradlew :projector-server:distZip
cd -

# build container:
DOCKER_BUILDKIT=1 docker build --progress=plain -t "$containerName" --build-arg "useLocalGradle=true" --build-arg "downloadUrl=$downloadUrl" -f Dockerfile .
