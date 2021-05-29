#!/bin/bash

# Example:
# wget https://addons.mozilla.org/firefox/downloads/file/3616824/foxyproxy_standard-7.5.1-an+fx.xpi -O /tmp/foxyproxy.xpi
# for i in $(echo ~/.mozilla/firefox/*.*/extensions/); do bash install_firefox_webextension.sh /tmp/foxyproxy.xpi "$i"; done

addon_xpi="$1"
addon_id="$(unzip -p $1 manifest.json | grep id | cut -d '"' -f 4)"
extension_path="$2$(basename $addon_id).xpi"
if [ -f "$extension_path" ]; then
    echo "Skipping $addon_xpi"
else
    cp "$addon_xpi" "$extension_path"
fi
