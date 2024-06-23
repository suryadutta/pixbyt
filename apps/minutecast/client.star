load("pixlib/file.star", "file")

def client.get_weather_response():

    output = file.exec("minutecast.py")
    return output["response"]
