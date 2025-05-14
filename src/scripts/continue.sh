#!/bin/bash
set -e

if [ -z "${CIRCLE_CONTINUATION_KEY}" ]; then
    echo "CIRCLE_CONTINUATION_KEY is required. Make sure setup workflows are enabled."
    exit 1
fi

if [ -z "${CONFIG_PATH}" ]; then
    echo "CONFIG_PATH is required."
    exit 1
fi

if ! which curl > /dev/null; then
    echo "curl is required to use this command"
    exit 1
fi

if ! which jq > /dev/null; then
    echo "jq is required to use this command"
    exit 1
fi

PARAMS=$([ -f "$PARAMETERS" ] && cat "$PARAMETERS" || echo "$PARAMETERS")
COMMAND=$(echo "$PARAMS" | jq . >/dev/null 2>&1)

if ! $COMMAND; then
    echo "PARAMETERS aren't valid json"
    exit 1
fi

mkdir -p /tmp/circleci
rm -rf /tmp/circleci/continue_post.json

# Escape the config as a JSON string.
jq -Rs '.' "$CONFIG_PATH" > /tmp/circleci/config-string.json

jq -n \
    --arg continuation "$CIRCLE_CONTINUATION_KEY" \
    --arg params "$PARAMS" \
    --slurpfile config /tmp/circleci/config-string.json \
    '{"continuation-key": $continuation, "configuration": $config|join("\n"), "parameters": $params|fromjson}' > /tmp/circleci/continue_post.json

cat /tmp/circleci/continue_post.json

MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RESPONSE=$(curl -i -s \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        --data @/tmp/circleci/continue_post.json \
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