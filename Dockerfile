FROM ubuntu

# copy projector files to the container:
ENV TO_CONTAINER_DIR /to-container
COPY to-container $TO_CONTAINER_DIR

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# move run scipt:
    && mv $TO_CONTAINER_DIR/run.sh run.sh \
# prepare tools:
    && apt-get update \
    && apt-get install wget -y \
    && apt-get install patch -y \
# TODO: should we remove this libraries?
    && apt-get install libxext6 libxrender1 libxtst6 libxi6 libfreetype6 -y \
# create the Projector dir:
    && export PROJECTOR_DIR=/projector \
    && mkdir -p $PROJECTOR_DIR \
# download IDEA to the $PROJECTOR_DIR/idea/ dir:
    && export IDEA_ARCHIVE_NAME=ideaIC-2019.3.1.tar.gz \
    && wget -q https://download.jetbrains.com/idea/$IDEA_ARCHIVE_NAME -O - | tar -xz \
    && find . -maxdepth 1 -type d -name "idea-*" -execdir mv {} $PROJECTOR_DIR/idea \; \
# apply projector-server:
    && mv $TO_CONTAINER_DIR/projector-server-1.0-SNAPSHOT.jar $PROJECTOR_DIR/idea \
    && patch $PROJECTOR_DIR/idea/bin/idea.sh < $TO_CONTAINER_DIR/idea.sh.patch \
##### REDUCING IMAGE SIZE: #####
# clean old dir:
    && rm -r $TO_CONTAINER_DIR \
# clean apt to reduce image size:
    && rm -rf /var/lib/apt/lists/*
