#!/bin/bash

# Example
#
# RANCHER_PROTOCOL=http RANCHER_URL=192.168.168.80 RANCHER_ACCESS_KEY=8B6C872C9CB615961F60 RANCHER_SECRET_KEY=9XuB1WHMvBY3WSyp2Zk9Lwc1MdAfTnHa93ci92Dw PROJECT_ID=1a5 STACK_NAME=MyStack SERVICE_NAME=Nginx ./restart_service.sh

RANCHER_ACCESS_KEY="$RANCHER_ACCESS_KEY"
RANCHER_SECRET_KEY="$RANCHER_SECRET_KEY"
RANCHER_PROTOCOL="$RANCHER_PROTOCOL"
RANCHER_URL="$RANCHER_URL"
PROJECT_ID="$PROJECT_ID"

STACK_NAME="$STACK_NAME"

SERVICE_NAME="$SERVICE_NAME"


#-------------------------------
TEMP_FILE_1="/tmp/tempfile1.txt"
TEMP_FILE_2="/tmp/tempfile2.txt"
#-------------------------------
cat /dev/null > $TEMP_FILE_1
cat /dev/null > $TEMP_FILE_2
#-------------------------------


#-------------------------------
# STEP 1

count_stacks=$(curl -f -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stacks | jq -r '.data[].name' | wc -l)

for ((i=0; i<$count_stacks; i++))
do
   cmd=$(echo "curl -f -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stacks | jq -r '.data[$i].name,.data[$i].id' ")
   echo $(eval $cmd) >> $TEMP_FILE_1
done

STACK_ID=$(cat $TEMP_FILE_1 | grep $STACK_NAME | awk '{print $2}')

#-------------------------------
# STEP 2

count_services=$(curl -f -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq '.data[] .name' | wc -l)

for ((i=0; i<$count_services; i++))
do
   cmd=$(echo "curl -f -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq -r '.data[$i] | .name,.id' ")
   echo $(eval $cmd) >> $TEMP_FILE_2
done

SERVICE_ID=$(cat $TEMP_FILE_2 | grep $SERVICE_NAME | awk '{print $2}')

#-------------------------------
# STEP 3

echo "Restarting..."

curl -f -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" \
-X POST \
-H 'Content-Type: application/json' \
-d '{
        "rollingRestartStrategy": {
                "batchSize": 1,
                "intervalMillis": 2000
        }
}' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/services/$SERVICE_ID?action=restart > /dev/null 2>&1

#-------------------------------

if [ "$?" -ne "0" ]; then echo "Error"; exit 127; else echo "Success"; exit 0; fi


