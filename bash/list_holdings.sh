#!/bin/bash

TMP='./.okapi'
OKAPI=`cat ${TMP}/url`
TOKEN=`cat ${TMP}/token`

curl --http1.1 -w '\n' "${OKAPI}/holdings-storage/holdings?limit=100" -H "x-okapi-token: ${TOKEN}"
