#!/bin/bash

# Has been tested on versions Elasticsearch 5.6.4(lucene 6.6.1) and 7.12.0(lucene 8.8.0)

# Simple query example (level 1)

#--------------------------------------------

URL="http://localhost:9200"

INDEX="index_name"

QUERY="field_name:search_value"

#CRED="--user login:password"

#--------------------------------------------

curl -s -k -XGET -H "Content-Type: application/json" "$URL/$INDEX/_search?q="$QUERY"&pretty" $CRED




############################################
######## R E A L    E X A M P L E ##########
#
# curl -s -k -XGET -H "Content-Type: application/json" "http://elastic.example.com/index_abc/_search?q=http_status_code:500&pretty" $CRED
#

