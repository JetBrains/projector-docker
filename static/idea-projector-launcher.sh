#!/bin/sh

IDE_RUN_FILE_NAME=idea

cp $IDE_RUN_FILE_NAME.sh $IDE_RUN_FILE_NAME-projector.sh

# change
# classpath "$CLASSPATH"
# to
# classpath "$CLASSPATH:$IDE_HOME/projector-server-1.0-SNAPSHOT.jar"
sed -i 's+classpath "$CLASSPATH"+classpath "$CLASSPATH:$IDE_HOME/projector-server-1.0-SNAPSHOT.jar"+g' $IDE_RUN_FILE_NAME-projector.sh

# change
# com.intellij.idea.Main
# to
# -Dcom.intellij.projector.server.classToLaunch=com.intellij.idea.Main com.intellij.projector.server.ProjectorLauncher
sed -i 's+com.intellij.idea.Main+-Dcom.intellij.projector.server.classToLaunch=com.intellij.idea.Main com.intellij.projector.server.ProjectorLauncher+g' $IDE_RUN_FILE_NAME-projector.sh

bash $IDE_RUN_FILE_NAME-projector.sh

rm $IDE_RUN_FILE_NAME-projector.sh
