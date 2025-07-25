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

if [ -f "$FILES_CHANGED" ] && [ -s "$FILES_CHANGED" ] && [ -n "$PARAMETER_FOR_FILES_CHANGED" ]; then
    files_json=$(paste -sd, "$FILES_CHANGED")
    PARAMS=$(echo "$PARAMS" | jq --arg files "$files_json" --arg param_name "$PARAMETER_FOR_FILES_CHANGED" '. + {$param_name: $files}')
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

[ "$(curl \
        --retry 5 \
        --retry-delay 0 \
        --retry-connrefused \
        -o /dev/stderr \
        -w '%{http_code}' \
        -XPOST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        --data @/tmp/circleci/continue_post.json \
        "https://${CIRCLECI_DOMAIN}/api/v2/pipeline/continue")" \
   -eq 200 ]
