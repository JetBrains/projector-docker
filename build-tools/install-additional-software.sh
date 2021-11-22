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

# Uncomment this in case uou need extra debug info
#set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
#set -x # Activate debugging to show execution details: all commands will be printed before execution

DOWNLOAD_URL=$1
# Define filter function
function string_filter {
  sed -z 's/  */ /g;s/\n//g' $1
}

# In SOFTWARE_LIST block add software package names. This string was directly passed to `apt install` command
# In ADDITIONAL_COMMANDS you can add any BASH commands. Please, note that you need to escape $ character by backslash (\)

# Detect type of IDE we use and create a list of required software
case $DOWNLOAD_URL in

#
# Block for CLion
  *CLion*)
    SOFTWARE_LIST=$(string_filter <<- EOM
      build-essential
      clang
EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for GoLand
  *goland*)
    SOFTWARE_LIST=$(string_filter <<- EOM

EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for DataGrip
  *datagrip*)
    SOFTWARE_LIST=$(string_filter <<- EOM

EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for PhpStorm
  *PhpStorm*)
    SOFTWARE_LIST=$(string_filter <<- EOM

EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for PyCharm
  *pycharm*)
    SOFTWARE_LIST=$(string_filter <<- EOM
        python2
        python3
        python3-distutils
        python3-pip
        python3-setuptools
EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for RubyMine
  *RubyMine*)
    SOFTWARE_LIST=$(string_filter <<- EOM

EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for WebStorm
  *WebStorm*)
    SOFTWARE_LIST=$(string_filter <<- EOM

EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM

EOM
    );;

#
# Block for Rider
  *Rider*)
    SOFTWARE_LIST=$(string_filter <<- EOM
        apt-transport-https
        dirmngr
        gnupg
        ca-certificates
        lsb-release
EOM
)
    ADDITIONAL_COMMANDS=$(string_filter <<- EOM
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&
        echo "deb https://download.mono-project.com/repo/\$(lsb_release -i -s | tr '[:upper:]' '[:lower:]') stable-\$(lsb_release -c -s) main" |
        tee /etc/apt/sources.list.d/mono-official-stable.list &&
        wget https://packages.microsoft.com/config/\$(lsb_release -i -s | tr '[:upper:]' '[:lower:]')/\$(lsb_release -r -s)/packages-microsoft-prod.deb &&
        dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb &&
        apt update &&
        DEBIAN_FRONTEND="nointeractive" \
        apt-get install -y dotnet-sdk-3.1 aspnetcore-runtime-3.1 mono-devel
EOM
    );;

esac

apt update
apt install -y${SOFTWARE_LIST}
sh -c "$ADDITIONAL_COMMANDS"
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt
