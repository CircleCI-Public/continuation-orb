#!/bin/bash

if ! which curl > /dev/null; then
    echo "curl is required to use this command"
    exit 1
fi

if ! which jq > /dev/null; then
    echo "jq is required to use this command"
    exit 1
fi

if ! which awk > /dev/null; then
    echo "awk is required to use this command"
    exit 1
fi

JSON_BODY=$( jq -n \
  --arg continuation "$CIRCLE_CONTINUATION_KEY" \
  '{"continuation-key": $continuation, "configuration": "{version: 2, jobs: {}, workflows: {version: 2}}", parameters: {}}'
)
echo "$JSON_BODY"

MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RESPONSE=$(curl -i -s \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        --data "${JSON_BODY}" \
        "https://${CIRCLECI_DOMAIN}/api/v2/pipeline/continue")
    HTTP_CODE=$(echo "$RESPONSE" | awk '/^HTTP/{code=$2} END{print code}')
    RETRY_AFTER=$(echo "$RESPONSE" | awk 'BEGIN{IGNORECASE=1} /^Retry-After:/ {print $2}' | tr -d '\r')
    if [ "$HTTP_CODE" -eq 429 ]; then
        WAIT=${RETRY_AFTER:-15}
        echo "Error too many requests. Retrying in $WAIT"
        sleep "$WAIT"
        ((RETRY_COUNT++))
    elif [ "$HTTP_CODE" -eq 200 ]; then
        exit 0
    else
        echo "Error: $HTTP_CODE"
        exit 1
    fi
done

echo "Max retries reached"
exit 1
