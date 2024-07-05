load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("time.star", "time")
load("humanize.star", "humanize")

GRADIENT_BAR_COLORS = [
    "D2222D", 
    "D2222D",
    "D2222D", 
    "D83826", 
    "DE4E20",
    "E56519",
    "EB7B13", 
    "F2920C", 
    "F8A806", 
    "FFBF00", 
    "DFB705", 
    "C0AF0A", 
    "A0A70F", 
    "819F14", 
    "619719", 
    "428F1E"
]

ALWAYS_SHOW = True

# Chicago
LAT = 41.87556
LON = -87.62442

def render_rain_box(precipitation):

    bar_height = min(int(3.5 * math.pow(precipitation, 0.62)),16)
    full_bar_colors = ["000" for _ in range(16-bar_height)] + reversed([GRADIENT_BAR_COLORS[15-i] for i in range(bar_height)])

    return render.Column(
        children=[
            render.Box(width=1, height=1, color=c)
            for c in full_bar_colors
        ]
    )

def main(config):

    timezone = "America/Chicago"

    # Get the current time
    current_time_str = humanize.time_format("HH:mm:ss", time.now().in_location(timezone))

    OPENWEATHERMAP_API_KEY = config.get("openweathermap_api_key")
    OPENWEATHERMAP_URI = "https://api.openweathermap.org/data/3.0/onecall?lat={}&lon={}&exclude=hourly,daily,alerts&appid={}&units=imperial".format(str(LAT), str(LON), OPENWEATHERMAP_API_KEY)

    rep = http.get(OPENWEATHERMAP_URI, ttl_seconds = 60)
    if rep.status_code != 200:
        fail("OpenWeatherMap request failed with status %d", rep.status_code)

    resp = rep.json()

    temp = resp["current"]["temp"]
    description = ", ".join([item["description"] for item in resp["current"]["weather"]])
    precipitation_intensities = [item["precipitation"] for item in resp["minutely"]]
    
    total_precipitation = 0
    for p in precipitation_intensities:
        total_precipitation = total_precipitation + p
    
    if total_precipitation == 0:
        description = "No precipitation for at least one hour"

    elif precipitation_intensities[0] == 0:
        for i in range(len(precipitation_intensities)):
            if precipitation_intensities[i] > 0:
                if i == 1:
                    description = "Rain starting in 1 minute"
                else:
                    description = "Rain starting in {} minutes".format(i)
                break

    elif precipitation_intensities[-1] == 0:
        for i in range(len(precipitation_intensities)):
            if reversed(precipitation_intensities)[i] > 0:
                ending_in_mins = len(precipitation_intensities) - i
                if ending_in_mins == 1:
                    description = "Rain ending in 1 minute"
                else:
                    description = "Rain ending in {} minutes".format(ending_in_mins)
                break

    description = "[{}] {}".format(current_time_str, description)

    if total_precipitation == 0 and not ALWAYS_SHOW:
        print("--no precipitation in next hour, skip showing widget--")
        return []

    else:
        return render.Root(
            child=render.Column(
                expanded=True,
                main_align="space_around",
                cross_align="center",
                children=[
                    render.Box(
                        width=60, 
                        height=16, 
                        color="#000",
                        child=render.Row(
                            children=[
                                render_rain_box(p) 
                                for p in precipitation_intensities
                            ]
                        )
                    ),
                    render.Marquee(
                        child=render.Text(description),
                        width=60,
                    ),
                    render.Box(
                        width=64, 
                        height=1, 
                        color="#000",
                    )
                ]
            )
        )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "openweathermap_api_key",
                name = "OpenWeatherMap API Key",
                desc = "API key for OpenWeatherMap data access",
                icon = "gear",
            ),
        ],
    )
