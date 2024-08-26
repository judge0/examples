#!/usr/bin/env bash
source ../.env

function generate_request_body() {
    cat << EOF
{
    "source_code": "$($JUDGE0_BASE64_CMD -w0 - < script.sql)",
    "language_id": 82,
    "additional_files": "$(zip -r - db.sqlite | $JUDGE0_BASE64_CMD -w0 -)"
}
EOF
}

function create_submission() {
    echo "[$(date)] Generating request body..." 1>&2
    generate_request_body > request_body.json
    echo "[$(date)] Creating submission..." 1>&2

    # Use these headers for RapidAPI
    # -H "X-RapidAPI-Key: $RAPIDAPI_KEY" \
    # -H "X-RapidAPI-Host: judge0-ce.p.rapidapi.com" \
    curl --progress-bar \
         --no-silent \
         -X POST \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $SULU_KEY" \
         --data @request_body.json \
         --output request_response.json \
         "$JUDGE0_CE_BASE_URL/submissions?base64_encoded=true&wait=false"
    cat request_response.json
}


function get_submission() {
    # Use these headers for RapidAPI
    # -H "X-RapidAPI-Key: $RAPIDAPI_KEY" \
    # -H "X-RapidAPI-Host: judge0-ce.p.rapidapi.com" \
    curl -H "Accept: application/json" \
         -H "Authorization: Bearer $SULU_KEY" \
         "$JUDGE0_CE_BASE_URL/submissions/$1?base64_encoded=true&fields=$2"
}

token="$(create_submission | jq -r ".token")"
if [[ "$token" == "null" ]]; then
    cat request_response.json | jq
    exit
fi

echo "[$(date)] Token: $token"

for i in {1..10}; do
    sleep $(( i / 2 ))

    status_id="$(get_submission "$token" "status" | jq -r ".status.id")"
    echo "[$(date)] Status ID: $status_id"

    if [[ "$status_id" != "1" && "$status_id" != "2" ]]; then
        break
    fi
done

submission_json="$(get_submission "$token" "status,stdout,stderr,compile_output,message")"

echo "[$(date)] Received submission:"
echo "$submission_json" | jq

echo "[$(date)] Base64 decoded stdout:"
echo "$submission_json" | jq -r ".stdout" | $JUDGE0_BASE64_CMD -d -
