#!/bin/bash

if ! which curl > /dev/null; then
    echo "curl is required to use this command"
    exit 1
fi

if ! which jq > /dev/null; then
    echo "jq is required to use this command"
    exit 1
fi

JSON_BODY=$( jq -n \
  --arg continuation "$CIRCLE_CONTINUATION_KEY" \
  '{"continuation-key": $continuation, "configuration": "{version: 2, jobs: {}, workflows: {version: 2}}", parameters: {}}'
)
echo "$JSON_BODY"

[[ $(curl \
        --retry 5 \
        --retry-delay 0 \
        --retry-connrefused \
        -o /dev/stderr \
        -w '%{http_code}' \
        -XPOST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        --data "${JSON_BODY}" \
        "https://${CIRCLECI_DOMAIN}/api/v2/pipeline/continue") \
   -eq 200 ]]
