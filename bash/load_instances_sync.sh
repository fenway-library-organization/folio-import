#!/bin/bash

TMP='./.okapi'
OKAPI=`cat ${TMP}/url`
TOKEN=`cat ${TMP}/token`

UFILE=$1;
if [ -z $UFILE ]
  then
    echo 'Usage: ./load_instance_sync.sh <instance_file>'
    exit
fi
if [ ! -f $UFILE ]
  then
    echo 'File not found'
    exit;
fi

curl -w '\n' --http1.1 "${OKAPI}/instance-storage/batch/synchronous" -H 'content-type: application/json' -H "x-okapi-token: ${TOKEN}" -d @$UFILE
