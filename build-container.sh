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
cp static/index.html.patch $TO_CONTAINER_DIR
cp static/nginx.conf.patch $TO_CONTAINER_DIR
cp static/run.sh $TO_CONTAINER_DIR
cp static/site.conf.patch $TO_CONTAINER_DIR

# build projector:
cd projector-core
./gradlew :projector-client-web:runDceKotlinJs
./gradlew :projector-server:jar
cd ../

# copy built projector:
cp projector-core/projector-client-web/build/kotlin-js-min/main/kotlin.js $TO_CONTAINER_DIR
cp projector-core/projector-client-web/build/kotlin-js-min/main/kotlinx-serialization-kotlinx-serialization-runtime.js $TO_CONTAINER_DIR
cp projector-core/projector-client-web/build/kotlin-js-min/main/projector-client-web.js $TO_CONTAINER_DIR
cp projector-core/projector-client-web/build/kotlin-js-min/main/projector-common.js $TO_CONTAINER_DIR
cp projector-core/projector-client-web/src/main/resources/index.html $TO_CONTAINER_DIR
cp projector-core/projector-client-web/src/main/resources/pj.png $TO_CONTAINER_DIR
cp projector-core/projector-server/build/libs/projector-server-1.0-SNAPSHOT.jar $TO_CONTAINER_DIR

# build container:
sudo docker build -t projector-image .
