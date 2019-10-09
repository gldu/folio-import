#!/bin/bash

TMP='./.okapi'
OKAPI=`cat ${TMP}/url`
TOKEN=`cat ${TMP}/token`
REFDIR=$1
if [ ! $1 ]
  then
    echo "Usage: ${0} <reference_data_directory>"
    exit
fi

if [ ! -d $REFDIR ]
  then
    mkdir $REFDIR
fi

PATHS='contributor-name-types contributor-types alternative-title-types call-number-types 
  classification-types electronic-access-relationships holdings-note-types holdings-types
  identifier-types ill-policies instance-formats instance-note-types instance-relationship-types
  instance-statuses instance-types item-damaged-statuses item-note-types loan-types locations location-units
  material-types modes-of-issuance nature-of-content-terms service-points shelf-locations statistical-code-types
  statistical-codes'
curl

for PATH in $PATHS
  do
    echo "Fetching ${PATH}"
    curl --http1.1 -o "${REFDIR}/${PATH}.json" -w "\n" "${OKAPI}/${PATH}?limit=100" -H "x-okapi-token: ${TOKEN}"
done
