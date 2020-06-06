#!/bin/bash

#
# GNU General Public License version 2
#
# Copyright (C) 2019-2020 JetBrains s.r.o.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

# search for IDE runner sh file:

THIS_FILE_NAME=$(basename "$0")

ideRunnerCandidates=($(grep -lr --include=*.sh com.intellij.idea.Main .))

# remove this file from candidates:
for i in "${!ideRunnerCandidates[@]}"; do
    if [[ ${ideRunnerCandidates[i]} = *$THIS_FILE_NAME* ]]; then
        unset 'ideRunnerCandidates[i]'
    elif [[ ${ideRunnerCandidates[i]} = *"projector"* ]]; then
        unset 'ideRunnerCandidates[i]'
    fi
done

if [[ ${#ideRunnerCandidates[@]} != 1 ]]; then
    echo "Can't find a single candidate to be IDE runner script so can't select a single one:"
    echo ${ideRunnerCandidates[*]}
    exit 1
fi

ideRunnerCandidate=${ideRunnerCandidates[@]}
ideRunnerWithoutPrefix=${ideRunnerCandidate/"./"/""}
IDE_RUN_FILE_NAME=${ideRunnerWithoutPrefix/".sh"/""}
echo "Found IDE: $IDE_RUN_FILE_NAME"

cp "$IDE_RUN_FILE_NAME.sh" "$IDE_RUN_FILE_NAME-projector.sh"

# change
# classpath "$CLASSPATH"
# to
# classpath "$CLASSPATH:$IDE_HOME/projector-server/lib/*"
sed -i 's+classpath "$CLASSPATH"+classpath "$CLASSPATH:$IDE_HOME/projector-server/lib/*"+g' "$IDE_RUN_FILE_NAME-projector.sh"

# change
# com.intellij.idea.Main
# to
# -Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher
sed -i 's+com.intellij.idea.Main+-Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher+g' "$IDE_RUN_FILE_NAME-projector.sh"

bash "$IDE_RUN_FILE_NAME-projector.sh"

rm "$IDE_RUN_FILE_NAME-projector.sh"

