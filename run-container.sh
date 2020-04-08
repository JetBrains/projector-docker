#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

containerName=${1:-projector-idea-c}

docker run --rm -p 8080:8080 -p 8887:8887 -it "$containerName" bash -c "nginx && ./run.sh"
