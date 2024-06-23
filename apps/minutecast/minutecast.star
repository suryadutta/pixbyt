load("render.star", "render")
load("pixlib/const.star", "const")
load("./client.star", "client")

def render_no_rain():
    return render.Box(width=1, height=16, color="#d")

def render_light_rain():
    return render.Box(width=1, height=16, color="#238823")

def render_medium_rain():
    return render.Box(width=1, height=16, color="#ffbf00")

def render_heavy_rain():
    return render.Box(width=1, height=16, color="#d2222d")

def render_rain_box(precipitation):
    if precipitation == 0:
        return render_no_rain()
    elif precipitation < 2.5:
        return render_light_rain()
    elif precipitation < 7.6:
        return render_medium_rain()
    else:
        return render_heavy_rain()

def main(config):

    response = client.get_weather_response()

    return render.Root(
        child=render.Column(
            expanded=True,
            main_align="space_around",
            cross_align="center",
            children=[
                render.Box(
                    width=60, 
                    height=16, 
                    color="#ccc",
                    child=render.Row(
                        children=[render_rain_box(precipitation) for precipitation in response["precipitation_intensities"]]
                    )
                ),
                render.Marquee(
                    child=render.Text(response["description"]),
                    width=const.WIDTH
                )
            ]
        )
    )
