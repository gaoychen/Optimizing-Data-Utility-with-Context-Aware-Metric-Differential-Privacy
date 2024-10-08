import folium

'''
This is to show you how we group the map of Rome into 20 sub-regions
'''

# Specify Rectangular Area Boundary (boundary of Rome)
southwest = [41.64, 12.23]
northeast = [42.12, 12.83]

# step size
lat_step = 0.12
lon_step = 0.12

m = folium.Map(location=[(southwest[0] + northeast[0]) / 2, (southwest[1] + northeast[1]) / 2], zoom_start=13)

lat = southwest[0]
while lat < northeast[0]:
    lon = southwest[1]
    while lon < northeast[1]:
        grid_sw = [lat, lon]
        grid_ne = [min(lat + lat_step, northeast[0]), min(lon + lon_step, northeast[1])]
        folium.Rectangle(
            bounds=[grid_sw, grid_ne],
            color="#ff7800",
            fill=False
        ).add_to(m)
        lon += lon_step
    lat += lat_step

m.save('grid_map.html')
