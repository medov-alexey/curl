#!/bin/bash

# Has been tested on versions Elasticsearch 5.6.4(lucene 6.6.1) and 7.12.0(lucene 8.8.0)

# Example request for getting quantity (level 3)

if [ "$(jq --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo "Please install linux utility - jq"; exit 127; fi

#--------------------------------------------

URL="http://localhost:9200"

INDEX="index_name"

QUERY="google.com OR yahoo.com"

TIMESTAMP_FIELD="@timestamp"

START_TIME="now-1d/d" # More Example: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-query.html

END_TIME="now/d"      # More Example: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-query.html

#CRED="--user login:password"

execute_file="/tmp/request.sh"


#--------------------------------------------

echo "curl -s -k -XGET -H \"Content-Type: application/json\" \"$URL/$INDEX/_count\" -d '{\"query\": {\"bool\": {\"must\": {\"query_string\": {\"query\": \"$QUERY\"}},\"filter\": {\"bool\": {\"must\": {\"range\": {\"$TIMESTAMP_FIELD\": {\"gt\":\"$START_TIME\", \"lte\":\"$END_TIME\" } } } } } } } }' $CRED | jq '.count' " > $execute_file

chmod +x $execute_file && sh $execute_file


#-------------- E X A M P L E ----------------

example_file="/tmp/example_of_request.txt"

echo "curl -s -k -XGET -H \"Content-Type: application/json\" \"https://elastic.example.com/index_123/_count\" -d '{\"query\": {\"bool\": {\"must\": {\"query_string\": {\"query\": \"Type:Nginx AND yandex.ru/market/id3434\" } },\"filter\": {\"bool\": {\"must\": {\"range\": {\"timestamp\": {\"gt\":\"2020-01-30 15:33:10.543\", \"lte\":\"now\", \"time_zone\":\"+03:00\" } } } } } } } }' --user admin:superpassword123" > $example_file

