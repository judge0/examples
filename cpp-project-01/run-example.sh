#!/bin/bash
RAPIDAPI_KEY="xxx"

# Zip files needed for running a project.
echo "Creating and encoding an archive with project content."
additional_files=$(zip -q -r - include/ src/ CMakeLists.txt compile run | base64 -w0 -)

# Create new submission.
echo "Creating new submission."
token=$(curl -X POST -H "Content-Type: application/json" -d "{\"language_id\": 89, \"additional_files\": \"$additional_files\"}" "http://localhost:8080/submissions?wait=false" | jq -r ".token" )
echo "Created submission with token: $token"

while true; do
    sleep 1

    echo "Checking submission status."
    submission=$(curl "http://localhost:8080/submissions/$token")

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

curl "http://localhost:8080/submissions/$token" | jq -M