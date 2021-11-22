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
RUN cd projector-server/build/distributions && find . -maxdepth 1 -type f -name projector-server-*.zip -exec mv {} projector-server.zip \;

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
COPY --from=projectorGradleBuilder $PROJECTOR_DIR/projector-server/projector-server/build/distributions/projector-server.zip $PROJECTOR_DIR
# prepare IDE - apply projector-server:
RUN unzip $PROJECTOR_DIR/projector-server.zip
RUN rm $PROJECTOR_DIR/projector-server.zip
RUN find . -maxdepth 1 -type d -name projector-server-* -exec mv {} projector-server \;
RUN mv projector-server $PROJECTOR_DIR/ide/projector-server
RUN mv $PROJECTOR_DIR/ide-projector-launcher.sh $PROJECTOR_DIR/ide/bin
RUN chmod 644 $PROJECTOR_DIR/ide/projector-server/lib/*

FROM debian:10

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# move run script:
    && apt update \
# packages for awt:
    && apt install -y libxext6 libxrender1 libxtst6 libxi6 libfreetype6 \
# packages for user convenience:
    git bash-completion wget \
# packages for IDEA (to disable warnings):
    procps \
# clean apt to reduce image size^
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt

# install specific packages for IDEs:
ARG downloadUrl
ADD projector-docker/build-tools/install-additional-software.sh /
RUN bash /install-additional-software.sh $downloadUrl \
# clean apt to reduce image size:
    && rm /install-additional-software.sh

# copy the Projector dir:
ENV PROJECTOR_DIR /projector
COPY --from=projectorStaticFiles $PROJECTOR_DIR $PROJECTOR_DIR

ENV PROJECTOR_USER_NAME projector-user

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# move run script:
    && mv $PROJECTOR_DIR/run.sh run.sh \
# change user to non-root (http://pjdietz.com/2016/08/28/nginx-in-docker-without-root.html):
    && mv $PROJECTOR_DIR/$PROJECTOR_USER_NAME /home \
    && useradd -m -d /home/$PROJECTOR_USER_NAME -s /bin/bash $PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /home/$PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME $PROJECTOR_DIR/ide/bin \
    && chown $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME run.sh

USER $PROJECTOR_USER_NAME
ENV HOME /home/$PROJECTOR_USER_NAME

EXPOSE 8887

CMD ["bash", "-c", "/run.sh"]
