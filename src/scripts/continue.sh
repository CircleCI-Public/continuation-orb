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

if ! jq . >/dev/null 2>&1 <<<"$PARAMS"; then
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

[[ $(curl \
        -o /dev/stderr \
        -w '%{http_code}' \
        -XPOST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        --data @/tmp/circleci/continue_post.json \
        "https://${CIRCLECI_DOMAIN}/api/v2/pipeline/continue") \
   -eq 200 ]]
