#!/bin/bash

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

CONTAINER_NAME=projector-idea-c
DOWNLOAD_URL=https://download.jetbrains.com/idea/ideaIC-2019.3.5.tar.gz

checkargs () {
    if [[ "$OPTARG" =~ ^-[u/n/h]$ ]]; then
        echo "Unknow argument $OPTARG for option $opt"
        exit 1
    fi
}

print_usage() {
    echo "Projector builder. Usage:
    pass '-n' option to set container name ($CONTAINER_NAME by default)
    pass '-u' option to set download url   ($DOWNLOAD_URL by default)
"
}

while getopts "n:u:h" opt; do
    case $opt in
        n) checkargs
            CONTAINER_NAME="$OPTARG";;
        u) checkargs
            DOWNLOAD_URL="$OPTARG";;
        h) print_usage
            exit 0
            ;;
        *) echo "Unsupported argument. Please, call with '-h' to see usage info"
            exit 1
            ;;
    esac
done

# build container:
DOCKER_BUILDKIT=1 docker build --progress=plain -t "$CONTAINER_NAME" --build-arg buildGradle=true --build-arg "downloadUrl=$DOWNLOAD_URL" -f Dockerfile ..
