#!/bin/bash

RANCHER_ACCESS_KEY="90535B152F522F613C26"
RANCHER_SECRET_KEY="QEoFGPwHC5GeyrCdeFqU1kZrgYKQQWYNSy7r1cGA"
RANCHER_URL="192.168.168.80"
PROJECT_ID="1a5"
STACK_ID="1st5"

#-------------------------------

count=$(curl -f -s -S -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' -d '{"rollingRestartStrategy": { "batchSize": 1, "intervalMillis": 2000 }}' http://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq '.data[] .name' | wc -l)

for ((i=0; i<$count; i++))
do
echo "curl -f -s -S -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' -d '{"rollingRestartStrategy": { "batchSize": 1, "intervalMillis": 2000 }}' http://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq --tab -r '.data[$i] | .name,.id' " > /tmp/test.txt; chmod +x /tmp/test.txt; echo $(sh /tmp/test.txt)
done

#-------------------------------



