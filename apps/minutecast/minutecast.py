import json
import requests

MINUTECAST_URI = "https://api.openweathermap.org/data/3.0/onecall?lat=41.87556&lon=-87.62442&exclude=hourly,daily,alerts&appid=ba0d2f43378772ae7a92ce7dddebec6c&units=imperial"

r = requests.get(MINUTECAST_URI)
response = r.json()

temp = response["current"]["temp"]
description = ", ".join(item["description"] for item in response["current"]["weather"])
precipitation_intensities = [item["precipitation"] for item in response["minutely"]]

output = {"response": {
    "temp": str(temp),
    "description": str(description),
    "precipitation_intensities": precipitation_intensities
}}

print(json.dumps(output))
