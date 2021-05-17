#!/bin/bash

RANCHER_ACCESS_KEY="8B6C872C9CB615961F60"
RANCHER_SECRET_KEY="9XuB1WHMvBY3WSyp2Zk9Lwc1MdAfTnHa93ci92Dw"
RANCHER_URL="192.168.168.80"
PROJECT_ID="1a5"
STACK_ID="1st5"

#-------------------------------

curl -f -s -S -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json'  http://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq -r '.data[] .name'

#-------------------------------



