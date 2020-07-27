#!/bin/bash
if [[ ! -v RAPIDAPI_KEY ]]; then
    echo "Please set RAPIDAPI_KEY environment variable." >&2
    exit 1
fi

JUDGE0_HOSTNAME="judge0.p.rapidapi.com"
JUDGE0_HOST="https://$JUDGE0_HOSTNAME"

# Zip files needed for running a project.
echo "Creating and encoding an archive with project content."
additional_files=$(zip -q -r - include/ src/ CMakeLists.txt compile run | base64 -w0 -)

# Create new submission.
echo "Creating new submission."
token=$(curl -X POST -H "Content-Type: application/json" -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: $JUDGE0_HOSTNAME" -d "{\"language_id\": 89, \"additional_files\": \"$additional_files\"}" "$JUDGE0_HOST/submissions?wait=false" | jq -r ".token" )
echo "Created submission with token: $token"

while true; do
    sleep 1

    echo "Checking submission status."
    submission=$(curl -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: $JUDGE0_HOSTNAME" "$JUDGE0_HOST/submissions/$token")

    status_id=$(echo $submission | jq -r ".status.id")
    status_description=$(echo $submission | jq -r ".status.description")

    if [[ $status_id -eq 1 || $status_id -eq 2 ]]; then
        echo "Submission status: $status_description ($status_id)"
        continue
    else
        echo "Done."
        break
    fi
done

curl -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: $JUDGE0_HOSTNAME" "$JUDGE0_HOST/submissions/$token" | jq -M