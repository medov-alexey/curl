#!/bin/bash

# Has been tested on versions Elasticsearch 5.6.4(lucene 6.6.1) and 7.12.0(lucene 8.8.0)

# Example request for getting quantity (level 3)

if [ "$(jq --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo "Please install linux utility - jq"; exit 127; fi

#--------------------------------------------

URL="http://localhost:9200"

INDEX="index_name"

QUERY="SEARCH QUERY"

TIMESTAMP_FIELD="@timestamp"

#CRED="--user login:password"

#--------------------------------------------

curl -s -k -XGET -H "Content-Type: application/json" "$URL/$INDEX/_count" -d '{
    "query": {
        "bool": {
            "must" : {
                "query_string": {
                    "query": "'"$QUERY"'"
                }
            },
            "filter": {
                "bool": {
                    "must": {
                       "range" : {
                          "'"$TIMESTAMP_FIELD"'": {
                                "gt":"2021-04-26 00:00:00.000",
                                "lte":"now",
                                "time_zone":"+03:00"
                           }
                        }
                    }
                }
            }
        }
    }
}' $CRED | jq '.count'


############################################
######## R E A L    E X A M P L E ##########
#
# curl -s -k -XGET -H "Content-Type: application/json" "https://elastic.example.com/index_123/_count" -d '{
#    "query": {
#        "bool": {
#            "must" : {
#                "query_string": {
#                    "query": "Type:Nginx AND (/market/price/349053)"
#                }
#            },
#            "filter": {
#                "bool": {
#                    "must": {
#                       "range" : {
#                          "timestamp": {
#                                "gt":"2020-01-30T15:33:10.543Z",
#                                "lte":"now",
#                                "time_zone":"+00:00"
#                           }
#                        }
#                    }
#                }
#            }
#        }
#    }
#}' $CRED
#
#
#
# Timestamp field values example: "2020-01-30T15:33:10.543Z" OR "2019-06-30 10:00:00.000" OR "now-1d/d" OR ...
#
#
