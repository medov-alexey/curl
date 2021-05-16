#!/bin/bash

RANCHER_ACCESS_KEY="90535B152F522F613C26"
RANCHER_SECRET_KEY="QEoFGPwHC5GeyrCdeFqU1kZrgYKQQWYNSy7r1cGA"
RANCHER_URL="192.168.168.80"
PROJECT_ID="1a5"
ID="1s7"

#-------------------------------

echo "Restarting..."

curl -f -s -S -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" \
-X POST \
-H 'Content-Type: application/json' \
-d '{
        "rollingRestartStrategy": {
                "batchSize": 1,
                "intervalMillis": 2000
        }
}' http://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/services/$ID?action=restart > /dev/null 2>&1

#-------------------------------

if [ "$?" -ne "0" ]; then echo "Error"; exit 127; else echo "Success"; exit 0; fi


