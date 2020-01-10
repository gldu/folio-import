#!/bin/bash

# This short script will take a glob of jobExcutions json files and create 
# source records.  See https://github.com/folio-org/mod-source-record-manager/blob/master/README.md

FILE=$1;
if [ -z $FILE ]
  then
    echo "Usage: ${0} <mappin_rules_file>"
    exit
fi

TMP='./.okapi'
OKAPI=`cat ${TMP}/url`
TOKEN=`cat ${TMP}/token`

if [ ! -d 'log' ]
  then
    mkdir 'log'
fi

for f in ${BASH_ARGV[*]}; do
  echo "Loading ${f}"
  #echo '' >> 'log/jobs.log'
  #echo $f >> 'log/jobs.log'
  curl --http1.1 -X PUT "${OKAPI}/mapping-rules" -H 'content-type: application/json' -H "x-okapi-token: ${TOKEN}" -d @$f
done
