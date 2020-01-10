#!/bin/sh

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately
set -x # Activate debugging to show execution details: all commands will be printed before execution

# create dir for transfrering projector files:
TO_CONTAINER_DIR=to-container
rm -r $TO_CONTAINER_DIR
mkdir $TO_CONTAINER_DIR

# copy static files:
cp static/idea.sh.patch $TO_CONTAINER_DIR
cp static/run.sh $TO_CONTAINER_DIR

# build projector:
cd projector-core
#./gradlew :projector-client-web:runDceKotlinJs -- todo: copy client to container too
./gradlew :projector-server:jar
cd ../

# copy built projector:
cp projector-core/projector-server/build/libs/projector-server-1.0-SNAPSHOT.jar $TO_CONTAINER_DIR

# build container:
sudo docker build -t projector-image .
