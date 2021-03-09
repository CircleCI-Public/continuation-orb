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

RAW_CONFIG=$(cat "$CONFIG_PATH")

PARAMS=$([ -f "$PARAMETERS" ] && cat "$PARAMETERS" || echo "$PARAMETERS")


if ! jq . >/dev/null 2>&1 <<<"$PARAMS"; then
    echo "PARAMETERS aren't valid json"
    exit 1
fi

mkdir -p /tmp/circleci
rm -rf /tmp/circleci/continue_post.json

JSON_BODY=$( jq -n \
  --arg continuation "$CIRCLE_CONTINUATION_KEY" \
  --arg config "$RAW_CONFIG" \
  --arg params "$PARAMS" \
  '{"continuation-key": $continuation, "configuration": $config, parameters: $params|fromjson}'
)

echo $JSON_BODY | jq -cr '' > /tmp/circleci/continue_post.json
cat /tmp/circleci/continue_post.json

[[ $(curl \
        -o /dev/stderr \
        -w '%{http_code}' \
        -XPOST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        -d @/tmp/circleci/continue_post.json \
        "https://circleci.com/api/v2/pipeline/continue") \
   -eq 200 ]]
