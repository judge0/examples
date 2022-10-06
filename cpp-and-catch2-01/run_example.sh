#!/bin/bash
source ../.env

function generate_request_body() {
    cat << EOF
{
    "source_code": "",
    "language_id": 89,
    "additional_files": "$(cd additional_files; zip -r - . | base64 -w0 -)"
}
EOF
}

function create_submission() {
    echo "[$(date)] Generating request body..." 1>&2
    generate_request_body > request_body.json
    echo "[$(date)] Creating submission..." 1>&2
    curl --progress-bar \
         --no-silent \
         -X POST \
         -H "Content-Type: application/json" \
         -H "X-RapidAPI-Key: $RAPIDAPI_KEY" \
         -H "X-RapidAPI-Host: judge0-ce.p.rapidapi.com" \
         --data @request_body.json \
         --output request_response.json \
         "https://judge0-ce.p.rapidapi.com/submissions?base64_encoded=true&wait=false"
    cat request_response.json
}

function get_submission() {
    curl -H "Accept: application/json" \
         -H "X-RapidAPI-Key: $RAPIDAPI_KEY" \
         -H "X-RapidAPI-Host: judge0-ce.p.rapidapi.com" \
         "https://judge0-ce.p.rapidapi.com/submissions/$1?base64_encoded=true&fields=$2"
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
echo "$submission_json" | jq -r ".stdout" | base64 -d -
