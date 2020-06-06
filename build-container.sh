#!/bin/sh

#
# GNU General Public License version 2
#
# Copyright (C) 2019-2020 JetBrains s.r.o.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

containerName=${1:-projector-idea-c}
downloadUrl=${2:-https://download.jetbrains.com/idea/ideaIC-2019.3.4.tar.gz}

# build container:
DOCKER_BUILDKIT=1 docker build --progress=plain -t "$containerName" --build-arg buildGradle=true --build-arg "downloadUrl=$downloadUrl" -f Dockerfile ..
