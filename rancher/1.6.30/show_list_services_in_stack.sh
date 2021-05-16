#!/bin/bash

RANCHER_ACCESS_KEY="90535B152F522F613C26"
RANCHER_SECRET_KEY="QEoFGPwHC5GeyrCdeFqU1kZrgYKQQWYNSy7r1cGA"
RANCHER_URL="192.168.168.80"
PROJECT_ID="1a5"
STACK_ID="1st5"

#-------------------------------

curl -f -s -S -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" \
-X GET \
-H 'Content-Type: application/json' \
-d '{
        "rollingRestartStrategy": {
                "batchSize": 1,
                "intervalMillis": 2000
        }
}' http://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq -r '.data[] .name'

#-------------------------------



