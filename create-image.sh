#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

containerName=${1:-projector-idea-c}
tarGzFileName=${2:-$containerName.tar.gz}

docker save "$containerName" | gzip > "$tarGzFileName"
