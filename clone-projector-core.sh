#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

git clone git@github.com:JetBrains/projector-client.git ../projector-client
git clone git@github.com:JetBrains/projector-markdown-plugin.git ../projector-markdown-plugin
git clone git@github.com:JetBrains/projector-server.git ../projector-server
