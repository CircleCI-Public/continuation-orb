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
        -o /dev/stderr \
        -w '%{http_code}' \
        -XPOST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json"  \
        --data "${JSON_BODY}" \
        "https://circleci.com/api/v2/pipeline/continue") \
   -eq 200 ]]
