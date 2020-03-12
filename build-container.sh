#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

# create dir for transfrering projector files:
TO_CONTAINER_DIR=to-container
rm -rf $TO_CONTAINER_DIR
mkdir $TO_CONTAINER_DIR

# copy static files:
cp -r static/projector-user $TO_CONTAINER_DIR/projector-user
cp static/idea.sh.patch $TO_CONTAINER_DIR
cp static/nginx.conf.patch $TO_CONTAINER_DIR
cp static/run.sh $TO_CONTAINER_DIR
cp static/site.conf.patch $TO_CONTAINER_DIR

# build projector:
cd projector-core
./gradlew :projector-client-web:browserProductionWebpack
./gradlew :projector-server:jar
cd ../

# copy built projector:
cp -r projector-core/projector-client-web/build/distributions $TO_CONTAINER_DIR/distributions
cp projector-core/projector-server/build/libs/projector-server-1.0-SNAPSHOT.jar $TO_CONTAINER_DIR

# build container:
sudo docker build -t projector-image .
