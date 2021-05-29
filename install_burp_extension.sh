#!/bin/bash

# Example:
# ./install_burp_extension.sh https://portswigger.net/bappstore/bapps/download/35237408a06043e9945a11016fcbac18

addon_url="$1"
addon_id=$(echo $addon_url | awk -F "/" '{print $NF}')
addon_dir=~/.BurpSuite/bapps

wget -q $addon_url -O /tmp/$addon_id.zip
unzip -q -o /tmp/$addon_id.zip -d $addon_dir/$addon_id

extension_type=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^ExtensionType:" | awk -F ": " '{print $2}')
if [[ $extension_type -eq '1' ]]; then extension_type="java"; else extension_type="python"; fi
if [[ $extension_type -eq 'java' ]]; then ext=".jar"; fi
if [[ $extension_type -eq 'python' ]]; then ext=".py"; fi

bapp_serial_version=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^SerialVersion:" | awk -F ": " '{print $2}')
bapp_uuid=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^Uuid:" | awk -F ": " '{print $2}')
extension_file=bapps/$addon_id/$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^EntryPoint:" | awk -F ": " '{print $2}')
name=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^Name:" | awk -F ": " '{print $2}')

read -r -d '' json <<- EOM
{
  "bapp_serial_version": $bapp_serial_version,
  "bapp_uuid": "$bapp_uuid",
  "errors": "ui",
  "extension_file": "$extension_file",
  "extension_type": "$extension_type",
  "loaded": true,
  "name": "$name",
  "output": "ui"
}
EOM

#echo $json | jq

cmd=$(echo $(echo "cat ~/.BurpSuite/UserConfigPro.json | jq '.user_options.extender.extensions[.user_options.extender.extensions| length] |= . + $(echo $(echo $json))'"))
eval "$cmd" > /tmp/int
cp /tmp/int ~/.BurpSuite/UserConfigPro.json

rm /tmp/int
rm /tmp/$addon_id.zip
