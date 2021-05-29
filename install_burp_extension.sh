#!/bin/bash

if [  $# -lt 1 ]; then 
  echo -e "Usage: $0 <BAPPSTORE_DOWNLOAD_URL>" 
  echo -e "e.g. $0 https://portswigger.net/bappstore/bapps/download/35237408a06043e9945a11016fcbac18" 
  exit 1
fi 

addon_url="$1"
addon_id=$(echo $addon_url | awk -F "/" '{print $NF}')
addon_dir=~/.BurpSuite/bapps

wget -q $addon_url -O /tmp/$addon_id.zip
unzip -q -o /tmp/$addon_id.zip -d $addon_dir/$addon_id

bapp_serial_version=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^SerialVersion:" | awk -F ": " '{print $2}' | sed 's/\r$//')
bapp_uuid=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^Uuid:" | awk -F ": " '{print $2}' | sed 's/\r$//')
extension_file=bapps/$addon_id/$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^EntryPoint:" | awk -F ": " '{print $2}' | sed 's/\r$//')
name=$(cat $addon_dir/$addon_id/BappManifest.bmf | grep -E "^Name:" | awk -F ": " '{print $2}' | sed 's/\r$//')

if echo $extension_file | grep -qE "\.jar$"; then extension_type=java
elif echo $extension_file | grep -qE "\.py$"; then extension_type=python
else extension_type=ruby; fi

jq --argjson sv $bapp_serial_version \
--arg uuid "$bapp_uuid" \
--arg ef "$extension_file" \
--arg et "$extension_type" \
--arg n "$name" \
'
.user_options.extender.extensions[.user_options.extender.extensions| length] |= . + 
{
  "bapp_serial_version": $sv,
  "bapp_uuid": $uuid,
  "errors": "ui",
  "extension_file": $ef,
  "extension_type": $et,
  "loaded": true,
  "name": $n,
  "output": "ui"
}
' \
~/.BurpSuite/UserConfigPro.json > /tmp/int

jq '.user_options.extender.extensions[.user_options.extender.extensions| length-1]' /tmp/int

cp /tmp/int ~/.BurpSuite/UserConfigPro.json

rm /tmp/int /tmp/$addon_id.zip
