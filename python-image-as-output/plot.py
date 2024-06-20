#!/usr/bin/env python3
import base64
import io
import json
import requests
import time
import zipfile


RAPID_API_KEY = "" # Get yours at https://judge0.com/extra-ce

JUDGE0_API_BASE = "https://judge0-extra-ce.p.rapidapi.com"
RAPID_API_HEADERS = {
    "X-RapidAPI-Key": RAPID_API_KEY,
    "X-RapidAPI-Host": "judge0-extra-ce.p.rapidapi.com",
}
JUDGE0_PENDING_STATUS_IDS = [1, 2]

# This is the script that will be executed. User writes this script.
# Instruction for the user is to create a plot and save it as image.png.
# Saving the plot as image.png is necessary because that is
# how we will later get the plot from the script.
SCRIPT = f"""
import matplotlib.pyplot as plt

# Define the circle
circle = plt.Circle((0, 0), 1, edgecolor='b', facecolor='none')

# Create a plot
fig, ax = plt.subplots()
ax.add_patch(circle)
ax.set_aspect('equal', 'box')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
plt.title('Circle')
plt.xlabel('X-axis')
plt.ylabel('Y-axis')
plt.grid(True)

plt.savefig('image.png')

print('hello, world')
"""

# This is the script instructs Judge0 how to run the user's script.
# In addtion to running the user's script, this script also reads the image.png
# and prints it to stderr. We will later get the image from stderr.
RUN_SCRIPT = f"""
source /usr/local/bin/conda_init
conda activate python3.11.2
python3 script.py

cat image.png | base64 -w0 1>&2
"""

# This function creates a zip file and returns the base64 encoded zip file.
# This is equivalent of creating a zip file and encoding it to base64 in Bash with:
# zip -r - . | base64 -w0 -
def create_zip(file_contents):
    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, "w") as zipf:
        for file_name, content in file_contents.items():
            zipf.writestr(file_name, content)

    return base64.b64encode(zip_buffer.getvalue()).decode("utf-8")


def run_script(script: str):
    # Preparing the payload for Judge0.
    # We are using language_id 89 which is "Multi-file program" which
    # allows you to run arbitrary scripts and projects in Judge0.
    # Language with ID 89 will look for a file called run.sh and execute it.
    # In our example this file activates python3.11.2 conda env and runs
    # the user's script. It also reads the image.png and prints it to stderr.
    data = {
        "additional_files": create_zip({"script.py": script, "run.sh": RUN_SCRIPT}),
        "language_id": 89
    }

    # Always send the data as base64 encoded with base64_encoded=true.
    res = requests.post(
        url=f"{JUDGE0_API_BASE}/submissions?base64_encoded=true",
        headers=RAPID_API_HEADERS,
        json=data,
    )

    token = json.loads(res.text)["token"]
    for _ in range(10):
        time.sleep(1)

        # Always request the output as base64 encoded with base64_encoded=true.
        res = requests.get(
            url=f"{JUDGE0_API_BASE}/submissions/{token}?base64_encoded=true",
            headers=RAPID_API_HEADERS,
            timeout=1,
        )

        content = res.json()

        status = content["status"]["id"]
        if status not in JUDGE0_PENDING_STATUS_IDS:
            break

    return content


def main():
    output = run_script(SCRIPT)

    # We first decode the stderr because Judge0 returns the output in base64.
    # Remember ?base64_encoded=true in the GET request? That is it.
    decoded_stderr = base64.b64decode(output["stderr"]).decode("utf-8")
    with open("image.png", "wb") as f:
        # We need to decode once again because run.sh script encoded the image.png
        f.write(base64.b64decode(decoded_stderr))


if __name__ == "__main__":
    main()
