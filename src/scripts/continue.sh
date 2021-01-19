if [ -z "${CIRCLE_CONTINUATION_KEY}" ]; then
    echo "CIRCLE_CONTINUATION_KEY is required. Make sure setup workflows are enabled."
    exit 1
fi

if [ -z "${CONFIG_PATH}" ]; then
    echo "CONFIG_PATH is required."
    exit 1
fi

RAW_CONFIG=$(cat "$CONFIG_PATH")

PARAMS=$([ -f "$PARAMETERS" ] && cat "$PARAMETERS" || echo "$PARAMETERS")


if ! jq . >/dev/null 2>&1 <<<"$PARAMS"; then
    echo "PARAMETERS aren't valid json"
    exit 1
fi

JSON_BODY=$( jq -n \
  --arg continuation "$CIRCLE_CONTINUATION_KEY" \
  --arg config "$RAW_CONFIG" \
  --arg params "$PARAMS" \
  '{"continuation-key": $continuation, "configuration": $config, parameters: $params}'
)
echo "$JSON_BODY"

curl \
  -XPOST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"  \
  --data "${JSON_BODY}" \
  "https://circleci.com/api/v2/pipeline/continue"
