#!/bin/bash

if [  $# -lt 1 ]; then 
  echo -e "Usage: $0 <JYTHON_PATH>" 
  echo -e "e.g. $0 ~/Documents/Resources/Java/jython-standalone-2.7.2.jar" 
  exit 1
fi 

jython="$1"
jq --arg j "$jython" \
	'.user_options.extender.python.location_of_jython_standalone_jar_file |= $j' \
	~/.BurpSuite/UserConfigPro.json > /tmp/int

jq '.user_options.extender.python' /tmp/int

cp /tmp/int ~/.BurpSuite/UserConfigPro.json
rm /tmp/int 
