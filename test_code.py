import requests
import json

url = "https://func-databricks-cea-dev.azurewebsites.net/api/messages"

payload = {
    "user": "Ankur",
    "message": "Hello from Python!"
}

headers = {
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers, verify=False  # disables SSL verification
                        )

print("Status Code:", response.status_code)
print("Response:", response.text)
