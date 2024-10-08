import pandas as pd
import numpy as np
import math
from datetime import datetime, timezone, timedelta
import os

'''
This is to show you how we group the data of Porto, you can get the 'train.csv' from the source link we provide in the paper
'''

def calculate_region(lon, lat):
    x = np.floor((lon + 8.73) / 0.08) + 1 #---
    y = np.floor((lat - 41.03) / 0.08) + 1
    out_of_bounds = (lon < -8.73) | (lon > -8.49) | (lat < 41.03) | (lat > 41.27)
    x[out_of_bounds] = 0
    y[out_of_bounds] = 0
    return x.astype(int), y.astype(int)

def haversine_distance(lon1, lat1, lon2, lat2):
    lon1, lat1, lon2, lat2 = map(np.asarray, (lon1, lat1, lon2, lat2))

    R = 3959  # Earth radius in miles
    phi1 = np.radians(lat1)
    phi2 = np.radians(lat2)
    delta_phi = np.radians(lat2 - lat1)
    delta_lambda = np.radians(lon2 - lon1)
    a = np.sin(delta_phi/2)**2 + np.cos(phi1) * np.cos(phi2) * np.sin(delta_lambda/2)**2
    c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1-a))
    return R * c

def process_coordinates(file_path, coordinates_per_group=3):
    df = pd.read_csv(file_path)
    df.columns = ['col1', 'type', 'col3', 'col4', 'col5', 'timestamp', 'col7', 'col8', 'coordinates']

    df['hour'] = pd.to_datetime(df['timestamp'], unit='s', utc=True).dt.tz_convert('Etc/GMT-1').dt.hour

    df['coordinates'] = df['coordinates'].apply(eval)

    type_mapping = {'A': '1', 'B': '2', 'C': '3'}

    for index, row in df.iterrows():
        coordinates = row['coordinates']
        hour = row['hour']
        type_value = type_mapping.get(row['type'], row['type'])

        for i in range(0, len(coordinates) - coordinates_per_group + 1, coordinates_per_group):
            group = coordinates[i:i+coordinates_per_group]
            lons, lats = zip(*group)

            # tuple to array
            lons = np.array(lons)
            lats = np.array(lats)

            region_x, region_y = calculate_region(lons, lats)

            if np.all(region_x == region_x[0]) and np.all(region_y == region_y[0]) and region_x[0] != 0 and region_y[0] != 0:
                distances = haversine_distance(lons[:-1], lats[:-1], lons[1:], lats[1:])
                total_distance = np.sum(distances)
                time_diff = (coordinates_per_group - 1) * 15 / 3600  # 15 seconds between each point, converted to hours
                speed = total_distance / time_diff if time_diff > 0 else 0

                speed_category = min(math.floor(speed / 5) * 5, 121)  # group by 5, Cap speed in case error data

                filename = f"lp-ci-test-main/data/Porto_taxi (srh)/08/all/Y={coordinates_per_group-2}/{speed_category}_{region_x[0]}_{region_y[0]}_{hour}.csv" #---

                with open(filename, 'a', newline='') as f:
                    np.savetxt(f, np.array(group).flatten().reshape(1, -1), delimiter=',', fmt='%f')

        if index % 1000 == 0:
            print(f"Processed {index} rows")

for i in range(1,6):
    process_coordinates('lp-ci-test-main/data/Porto_taxi (csv)/train.csv', coordinates_per_group=i+2)