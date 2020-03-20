FROM debian AS ideaDownloader

# prepare tools:
RUN apt-get update
RUN apt-get install wget -y
# download idea to the idea/ dir:
ENV IDEA_ARCHIVE_NAME ideaIC-2019.3.4.tar.gz
RUN wget -q https://download.jetbrains.com/idea/$IDEA_ARCHIVE_NAME -O - | tar -xz
RUN find . -maxdepth 1 -type d -name "idea-*" -execdir mv {} /idea \;

FROM amazoncorretto:11 as projectorGradleBuilder

# copy projector-core:
ENV PROJECTOR_DIR /projector
ADD projector-core-copy $PROJECTOR_DIR/projector-core
# build projector-core:
WORKDIR $PROJECTOR_DIR/projector-core
RUN ./gradlew clean
RUN ./gradlew :projector-client-web:browserProductionWebpack
RUN rm projector-client-web/build/distributions/projector-client-web.js.map
RUN ./gradlew :projector-server:jar

FROM debian AS projectorStaticFiles

# prepare tools:
RUN apt-get update
RUN apt-get install patch -y
# create the Projector dir:
ENV PROJECTOR_DIR /projector
RUN mkdir -p $PROJECTOR_DIR
# copy projector files to the container:
ADD static $PROJECTOR_DIR
# copy idea:
COPY --from=ideaDownloader /idea $PROJECTOR_DIR/idea
# copy projector:
COPY --from=projectorGradleBuilder $PROJECTOR_DIR/projector-core/projector-client-web/build/distributions $PROJECTOR_DIR/distributions
COPY --from=projectorGradleBuilder $PROJECTOR_DIR/projector-core/projector-server/build/libs/projector-server-1.0-SNAPSHOT.jar $PROJECTOR_DIR
# prepare idea - apply projector-server:
RUN mv $PROJECTOR_DIR/projector-server-1.0-SNAPSHOT.jar $PROJECTOR_DIR/idea
RUN patch $PROJECTOR_DIR/idea/bin/idea.sh < $PROJECTOR_DIR/idea.sh.patch
RUN rm $PROJECTOR_DIR/idea.sh.patch

FROM nginx

RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
   && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
   && set -x \
# install packages:
    && apt-get update \
    && apt-get install libxext6 libxrender1 libxtst6 libxi6 libfreetype6 -y \
    && apt-get install patch -y \
    && apt-get install git -y \
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
# prepare nginx:
    && mkdir -p /usr/share/nginx/html/projector \
    && mv $PROJECTOR_DIR/distributions/* /usr/share/nginx/html/projector/ \
    && rm -rf $PROJECTOR_DIR/distributions \
# change user to non-root (http://pjdietz.com/2016/08/28/nginx-in-docker-without-root.html):
    && patch /etc/nginx/nginx.conf < $PROJECTOR_DIR/nginx.conf.patch \
    && rm $PROJECTOR_DIR/nginx.conf.patch \
    && patch /etc/nginx/conf.d/default.conf < $PROJECTOR_DIR/site.conf.patch \
    && rm $PROJECTOR_DIR/site.conf.patch \
    && touch /var/run/nginx.pid \
    && mv $PROJECTOR_DIR/$PROJECTOR_USER_NAME /home \
    && useradd -m -d /home/$PROJECTOR_USER_NAME -s /bin/bash $PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /home/$PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /usr/share/nginx \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /var/cache/nginx \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /var/run/nginx.pid \
    && chown $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME run.sh

USER $PROJECTOR_USER_NAME
ENV HOME /home/$PROJECTOR_USER_NAME
