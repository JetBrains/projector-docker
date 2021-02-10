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

FROM debian AS ideDownloader

# prepare tools:
RUN apt-get update
RUN apt-get install wget -y
# download IDE to the /ide dir:
WORKDIR /download
ARG downloadUrl
RUN wget -q $downloadUrl -O - | tar -xz
RUN find . -maxdepth 1 -type d -name * -execdir mv {} /ide \;

FROM amazoncorretto:11 as projectorGradleBuilder

ENV PROJECTOR_DIR /projector

# projector-server:
ADD projector-server $PROJECTOR_DIR/projector-server
WORKDIR $PROJECTOR_DIR/projector-server
ARG buildGradle
RUN if [ "$buildGradle" = "true" ]; then ./gradlew clean; else echo "Skipping gradle build"; fi
RUN if [ "$buildGradle" = "true" ]; then ./gradlew :projector-server:distZip; else echo "Skipping gradle build"; fi

FROM debian AS projectorStaticFiles

# prepare tools:
RUN apt-get update
RUN apt-get install unzip -y
# create the Projector dir:
ENV PROJECTOR_DIR /projector
RUN mkdir -p $PROJECTOR_DIR
# copy IDE:
COPY --from=ideDownloader /ide $PROJECTOR_DIR/ide
# copy projector files to the container:
ADD projector-docker/static $PROJECTOR_DIR
# copy projector:
COPY --from=projectorGradleBuilder $PROJECTOR_DIR/projector-server/projector-server/build/distributions/projector-server-1.0-SNAPSHOT.zip $PROJECTOR_DIR
# prepare IDE - apply projector-server:
RUN unzip $PROJECTOR_DIR/projector-server-1.0-SNAPSHOT.zip
RUN rm $PROJECTOR_DIR/projector-server-1.0-SNAPSHOT.zip
RUN mv projector-server-1.0-SNAPSHOT $PROJECTOR_DIR/ide/projector-server
RUN mv $PROJECTOR_DIR/ide-projector-launcher.sh $PROJECTOR_DIR/ide/bin
RUN chmod 644 $PROJECTOR_DIR/ide/projector-server/lib/*

FROM debian:10

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
   && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
   && set -x \
# install packages:
    && apt-get update \
# packages for awt:
    && apt-get install libxext6 libxrender1 libxtst6 libxi6 libfreetype6 -y \
# packages for user convenience:
    && apt-get install git -y \
# packages for IDEA (to disable warnings):
    && apt-get install procps -y \
# clean apt to reduce image size:
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt

ARG downloadUrl

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# install specific packages for IDEs:
    && apt-get update \
    && if [ "${downloadUrl#*CLion}" != "$downloadUrl" ]; then apt-get install build-essential clang -y; else echo "Not CLion"; fi \
    && if [ "${downloadUrl#*pycharm}" != "$downloadUrl" ]; then apt-get install python2 python3 python3-distutils python3-pip python3-setuptools -y; else echo "Not pycharm"; fi \
    && if [ "${downloadUrl#*rider}" != "$downloadUrl" ]; then apt install apt-transport-https dirmngr gnupg ca-certificates -y && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list && apt update && apt install mono-devel -y && apt install wget -y && wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && apt-get update && apt-get install -y apt-transport-https && apt-get update && apt-get install -y dotnet-sdk-3.1 aspnetcore-runtime-3.1; else echo "Not rider"; fi \
# clean apt to reduce image size:
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt

# copy the Projector dir:
ENV PROJECTOR_DIR /projector
COPY --from=projectorStaticFiles $PROJECTOR_DIR $PROJECTOR_DIR

ENV PROJECTOR_USER_NAME projector-user

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# move run scipt:
    && mv $PROJECTOR_DIR/run.sh run.sh \
# change user to non-root (http://pjdietz.com/2016/08/28/nginx-in-docker-without-root.html):
    && mv $PROJECTOR_DIR/$PROJECTOR_USER_NAME /home \
    && useradd -m -d /home/$PROJECTOR_USER_NAME -s /bin/bash $PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /home/$PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME $PROJECTOR_DIR/ide/bin \
    && chown $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME run.sh

USER $PROJECTOR_USER_NAME
ENV HOME /home/$PROJECTOR_USER_NAME

CMD ["bash", "-c", "/run.sh"]
