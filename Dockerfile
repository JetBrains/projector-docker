FROM debian AS ideaDownloader

# prepare tools:
RUN apt-get update
RUN apt-get install wget -y
# download idea to the idea/ dir:
ENV IDEA_ARCHIVE_NAME ideaIC-2019.3.2.tar.gz
RUN wget -q https://download.jetbrains.com/idea/$IDEA_ARCHIVE_NAME -O - | tar -xz
RUN find . -maxdepth 1 -type d -name "idea-*" -execdir mv {} /idea \;

FROM debian AS projectorStaticFiles

# prepare tools:
RUN apt-get update
RUN apt-get install patch -y
# create the Projector dir:
ENV PROJECTOR_DIR /projector
RUN mkdir -p $PROJECTOR_DIR
# copy projector files to the container:
COPY to-container $PROJECTOR_DIR
# prepare index.html (TODO: this won't be needed after Kotlin/JS 1.3.70):
RUN patch $PROJECTOR_DIR/index.html < $PROJECTOR_DIR/index.html.patch
RUN rm $PROJECTOR_DIR/index.html.patch
# copy idea:
COPY --from=ideaDownloader /idea $PROJECTOR_DIR/idea
# prepare idea - apply projector-server:
RUN mv $PROJECTOR_DIR/projector-server-1.0-SNAPSHOT.jar $PROJECTOR_DIR/idea
RUN patch $PROJECTOR_DIR/idea/bin/idea.sh < $PROJECTOR_DIR/idea.sh.patch
RUN rm $PROJECTOR_DIR/idea.sh.patch

FROM nginx

# copy the Projector dir:
ENV PROJECTOR_DIR /projector
COPY --from=projectorStaticFiles $PROJECTOR_DIR $PROJECTOR_DIR

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# move run scipt:
    && mv $PROJECTOR_DIR/run.sh run.sh \
# prepare nginx:
    && mkdir -p /usr/share/nginx/html/projector \
    && mv $PROJECTOR_DIR/kotlin.js /usr/share/nginx/html/projector/ \
    && mv $PROJECTOR_DIR/kotlinx-serialization-kotlinx-serialization-runtime.js /usr/share/nginx/html/projector/ \
    && mv $PROJECTOR_DIR/projector-client-web.js /usr/share/nginx/html/projector/ \
    && mv $PROJECTOR_DIR/projector-common.js /usr/share/nginx/html/projector/ \
    && mv $PROJECTOR_DIR/index.html /usr/share/nginx/html/projector/ \
    && mv $PROJECTOR_DIR/pj.png /usr/share/nginx/html/projector/ \
# install libraries:
    && apt-get update \
    && apt-get install libxext6 libxrender1 libxtst6 libxi6 libfreetype6 -y \
##### REDUCING IMAGE SIZE: #####
# clean apt to reduce image size:
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt
