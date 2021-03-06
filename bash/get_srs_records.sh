#!/bin/bash

TMP='./.okapi'
OKAPI=`cat ${TMP}/url`
TOKEN=`cat ${TMP}/token`

if [ $1 ] 
  then
    QUERY="&query=snapshotId=${1}"
fi

curl --http1.1 -w '\n' "${OKAPI}/source-storage/records?limit=100${QUERY}" -H "x-okapi-token: ${TOKEN}"
