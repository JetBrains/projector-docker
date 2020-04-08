#!/bin/bash

set -e # Any command which returns non-zero exit code will cause this shell script to exit immediately

configDirRegex='VM_OPTIONS_FILE="(.*\$HOME.*)\/.*\.vmoptions"'

configDirCandidates=($(grep -ohrE --include=*.sh "$configDirRegex" /projector/ide/bin))

# map candidates to the matches:
for i in "${!configDirCandidates[@]}"; do
    if [[ ${configDirCandidates[i]} =~ $configDirRegex ]]; then
        configDirCandidates[i]="${BASH_REMATCH[1]}"
    else
        unset 'configDirCandidates[i]'
    fi
done

if [[ ${#configDirCandidates[@]} != 1 ]]; then
    echo "Can't find a single candidate to be IDE config dir so can't select a single one:"
    echo "${configDirCandidates[*]}"
    exit 1
fi

configDir=${configDirCandidates[@]}

echo "Found IDE config dir: $configDir"

mdPluginEnablerFile="/projector/ide/bin/mdPluginEnablerFile.sh"
touch "$mdPluginEnablerFile"
chmod +x "$mdPluginEnablerFile"
echo "mkdir -p \"$configDir\"" >> "$mdPluginEnablerFile"
echo "cp /projector/disabled_plugins.txt $configDir/" >> "$mdPluginEnablerFile"
echo "mkdir -p \"$configDir/plugins\"" >> "$mdPluginEnablerFile"
echo "rm -r $configDir/plugins/projector-plugin-markdown" >> "$mdPluginEnablerFile"
echo "cp -r /projector/projector-plugin-markdown $configDir/plugins/projector-plugin-markdown" >> "$mdPluginEnablerFile"
."$mdPluginEnablerFile"
