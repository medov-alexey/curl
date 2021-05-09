#!/bin/bash

# GCMR - Get Count Of Messages On Request

# Has been tested on versions Elasticsearch 5.6.4(lucene 6.6.1) and 7.12.0(lucene 8.8.0)

# Example request for getting quantity (level 3)

#--------------------------------------------

if [ "$1" == "help" ] || [ "$1" == "HELP" ]; then
    echo -e "\nExample for use:\n\n$0 \"http://localhost:9200\" \"mysql_index\" \"Type:Nginx AND Htth_Method:502\" \"@timestamp\" \"2021-01-31T06:00:00.000Z\" \"2021-01-31T18:00:00.000Z\" \n"
    echo -e "OR \n"
    echo -e "$0 \"https://elastic.example.com\" \"myindex\" \"dollar OR euro\" \"Timestamp\" \"2022-05-15T18:00:00.000Z\" \"2023-08-31T22:30:57.000Z\" \"--user login:password\" \n"
    echo -e "---------------------------------------------------------------------------------"
    echo -e "\nMore information: https://github.com/medov-alexey/curl/blob/master/elasticsearch \n"
    echo -e "---------------------------------------------------------------------------------"
    exit 0
fi

#--------------------------------------------

if [ "$(jq --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo "Please install linux utility - jq"; exit 103; fi

#--------------------------------------------

URL="$URL"

INDEX="$INDEX"

QUERY="$QUERY"

TIMESTAMP_FIELD="$TIMESTAMP_FIELD"

START_TIME="$START_TIME"

END_TIME="$END_TIME"

CRED="$CRED"

#--------------------------------------------

metrics_file="/usr/share/nginx/html/metrics"

#--------------------------------------------

execute_file="/tmp/request.sh"

echo "curl --stderr - -s -S -k -XGET -H \"Content-Type: application/json\" \"$URL/$INDEX/_count\" -d '{\"query\": {\"bool\": {\"must\": {\"query_string\": {\"query\": \"$QUERY\"}},\"filter\": {\"bool\": {\"must\": {\"range\": {\"$TIMESTAMP_FIELD\": {\"gt\":\"$START_TIME\", \"lte\":\"$END_TIME\" } } } } } } } }' $CRED 2> /dev/null | jq '.count' 2> /dev/null " > $execute_file

chmod +x $execute_file

#--------------------------------------------

result=$(sh $execute_file)

if [ "$?" -ne "0" ]; then echo "Failed to connect to Elasticsearch on $1";exit 104;fi

if [ "$(echo $result)" == "null" ]; then echo "Problem with one of the arguments you passed. Check again carefully how you ran the command $0"; else echo el_count_message $result > $metrics_file;fi




