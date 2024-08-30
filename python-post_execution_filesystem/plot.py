#!/usr/bin/env python3
import base64
import json
import requests
import time


RAPID_API_KEY = "" # Get yours at https://judge0.com/extra-ce
SULU_API_KEY = "" # Get your at https://sparkhub.sulu.sh

JUDGE0_API_BASE = "https://judge0-extra-ce.p.sulu.sh"
RAPID_API_HEADERS = {
    "X-RapidAPI-Key": RAPID_API_KEY,
    "X-RapidAPI-Host": "judge0-extra-ce.p.rapidapi.com",
}
SULU_API_HEADERS = {
    "Authorization": f"Bearer {SULU_API_KEY}"
}

JUDGE0_PENDING_STATUS_IDS = [1, 2]

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


def run_script(script: str):
    data = {
        "source_code": base64.b64encode(script.encode("utf-8")).decode("utf-8"),
        "language_id": 25
    }

    # Always send the data as base64 encoded with base64_encoded=true.
    res = requests.post(
        url=f"{JUDGE0_API_BASE}/submissions?base64_encoded=true",
        # headers=RAPID_API_HEADERS,
        headers=SULU_API_HEADERS,
        json=data,
    )

    token = json.loads(res.text)["token"]
    for _ in range(10):
        time.sleep(1)

        res = requests.get(
            url=f"{JUDGE0_API_BASE}/submissions/{token}?base64_encoded=true&fields=*",
            # headers=RAPID_API_HEADERS,
            headers=SULU_API_HEADERS,
            timeout=1,
        )

        content = res.json()

        status = content["status"]["id"]
        if status not in JUDGE0_PENDING_STATUS_IDS:
            break

    return content


def main():
    output = run_script(SCRIPT)

    decoded_post_execution_filesystem = base64.b64decode(output["post_execution_filesystem"])
    with open("post_execution_filesystem.zip", "wb") as f:
        f.write(decoded_post_execution_filesystem)


if __name__ == "__main__":
    main()
