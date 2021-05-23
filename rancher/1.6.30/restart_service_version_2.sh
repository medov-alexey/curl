#!/bin/bash

# Example
#
# RANCHER_PROTOCOL=http RANCHER_URL=192.168.168.80 RANCHER_ACCESS_KEY=8B6C872C9CB615961F60 RANCHER_SECRET_KEY=9XuB1WHMvBY3WSyp2Zk9Lwc1MdAfTnHa93ci92Dw PROJECT_ID=1a5 STACK_NAME=MyStack SERVICE_NAME=Nginx ./restart_service.sh

if [ "$(jq --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo "Please install linux utility - jq"; exit 103; fi
if [ "$(curl --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo "Please install linux utility - curl"; exit 104; fi
if [ "$(wget --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo "Please install linux utility - wget"; exit 105; fi

#-------------------------------

if [ -z "$RANCHER_ACCESS_KEY" ]; then echo "Error: the value of the variable RANCHER_ACCESS_KEY is not set";exit 40;fi
if [ -z "$RANCHER_SECRET_KEY" ]; then echo "Error: the value of the variable RANCHER_SECRET_KEY is not set";exit 41;fi
if [ -z "$RANCHER_PROTOCOL" ]; then echo "Error: the value of the variable RANCHER_PROTOCOL is not set";exit 42;fi
if [ -z "$RANCHER_URL" ]; then echo "Error: the value of the variable RANCHER_URL is not set";exit 43;fi
if [ -z "$PROJECT_ID" ]; then echo "Error: the value of the variable PROJECT_ID is not set";exit 44;fi
if [ -z "$STACK_NAME" ]; then echo "Error: the value of the variable STACK_NAME is not set";exit 45;fi
if [ -z "$SERVICE_NAME" ]; then echo "Error: the value of the variable SERVICE_NAME is not set";exit 46;fi

#-------------------------------

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
TEMP_FILE_3="/tmp/tcount"
TEMP_FILE_4="/tmp/tcode"
#-------------------------------
cat /dev/null > $TEMP_FILE_1
cat /dev/null > $TEMP_FILE_2
cat /dev/null > $TEMP_FILE_3
cat /dev/null > $TEMP_FILE_4
#-------------------------------



#-------------------------------
# STEP 0 - Check connect to server

curl --connect-timeout 3 --max-time 3 -k -s -S -O /dev/null -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" $RANCHER_PROTOCOL://$RANCHER_URL > /dev/null 2>&1

if [ "$?" -ne "0" ]; then echo $(echo "$(date +"%F-----%H:%M:%S") - Error - Server $RANCHER_PROTOCOL://$RANCHER_URL is not available"); exit 127; fi

wget --connect-timeout=3 -T 3 -S --no-check-certificate -O $TEMP_FILE_3 --user "$RANCHER_ACCESS_KEY" --password "$RANCHER_SECRET_KEY" -X POST --header=Content-Type:application/json $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stacks > $TEMP_FILE_4 2>&1

cat $TEMP_FILE_4 | grep "HTTP/" | tail -n 1 | grep 403 > /dev/null 2>&1

if [ "$?" -eq "0" ]; then echo "$(date +"%F-----%H:%M:%S") - Error - Please check Rancher PROJECT_ID"; exit 127; fi



#-------------------------------
# STEP 1 - Check stacks count

wget --connect-timeout=3 -T 3 -q -S --no-check-certificate -O $TEMP_FILE_3 --user "$RANCHER_ACCESS_KEY" --password "$RANCHER_SECRET_KEY" -X POST --header=Content-Type:application/json $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stacks > $TEMP_FILE_4 2>&1; 

if [ "$?" -ne "0" ]; then echo $(echo "$(date +"%F-----%H:%M:%S") - Error - $(cat $TEMP_FILE_4 | grep "HTTP/" | tail -n 1)"); exit 127; fi

count_stacks=$(cat $TEMP_FILE_3 | jq -r '.data[].name' | wc -l)



#-------------------------------
# STEP 2 - Find stack id

for ((i=0; i<$count_stacks; i++))
do
   cmd=$(echo "curl -f --connect-timeout 3 --max-time 3 -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stacks | jq -r '.data[$i].name,.data[$i].id' ")
   echo $(eval $cmd) >> $TEMP_FILE_1
done

STACK_ID=$(cat $TEMP_FILE_1 | grep "^$STACK_NAME\s" | awk '{print $2}')

if [ -z "$STACK_ID" ]; then echo "$(date +"%F-----%H:%M:%S") - Error - Stack $STACK_NAME not found";exit 48;fi

rm -rf $TEMP_FILE_1



#-------------------------------
# STEP 3 - Find service id

count_services=$(curl -f --connect-timeout 3 --max-time 3 -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq '.data[] .name' | wc -l)

for ((i=0; i<$count_services; i++))
do
   cmd=$(echo "curl -f --connect-timeout 3 --max-time 3 -s -S -k -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" -X GET -H 'Content-Type: application/json' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/stack/$STACK_ID/services | jq -r '.data[$i] | .name,.id' ")
   echo $(eval $cmd) >> $TEMP_FILE_2
done

SERVICE_ID=$(cat $TEMP_FILE_2 | grep "^$SERVICE_NAME\s" | awk '{print $2}')

if [ -z "$SERVICE_ID" ]; then echo "$(date +"%F-----%H:%M:%S") - Error - Service $SERVICE_NAME not found";exit 49;fi

rm -rf $TEMP_FILE_2



#-------------------------------
# STEP 4 - Restart service

wget --connect-timeout=3 -T 3 --no-check-certificate -O /dev/null -S --user "$RANCHER_ACCESS_KEY" --password "$RANCHER_SECRET_KEY" -X POST --header=Content-Type:application/json --post-data '{"rollingRestartStrategy": {"batchSize": 1, "intervalMillis": 2000}}' $RANCHER_PROTOCOL://$RANCHER_URL/v2-beta/projects/$PROJECT_ID/services/$SERVICE_ID?action=restart > $TEMP_FILE_4 2>&1

if [ "$?" -ne "0" ]; then echo $(echo "$(date +"%F-----%H:%M:%S") - Error - Restart: $(cat $TEMP_FILE_4 | grep "HTTP/" | tail -n 1)."); exit 127; else rm -rf $TEMP_FILE_3 $TEMP_FILE_4; echo "$(date +"%F-----%H:%M:%S") - Success - Restart"; exit 0; fi



