from flask import Flask, jsonify, request
import firebase_admin
import pandas as pd
from sklearn.neighbors import NearestNeighbors
import json
from math import sin, cos, sqrt, atan2, radians
from firebase_admin import credentials, firestore

app = Flask(__name__)

cred = credentials.Certificate("fir-hail-ec5a7-firebase-adminsdk-9d92w-d67984762b.json")
firebase_admin.initialize_app(cred)

def haversine_distance(lat1, lon1, lat2, lon2):
    # Calculate Haversine distance between two points with latitude and longitude
    R = 6371  # Radius of Earth in kilometers
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distance = R * c
    return distance

def preprocess_data(places):
    # Preprocess the data to handle categorical variables
    df = pd.DataFrame(places)
    place_names = {place['place_id']: place.get('placeName', 'Unknown') for place in places}

    # Drop unnecessary columns
    df = df.drop(columns=['placeName','User_id', 'images', 'description', 'allowChildren', 'WorkedDays',
                          'hasValetServiced', 'serves', 'atmosphere','INorOUT',
                          'hasCinema', 'hasFoodCourt', 'hasPlayArea', 'hasSupermarket',
                          'startDate', 'neighbourhood', 'finishDate', 'WebLink',
                          'hasReservation', 'reservationDetails', 'shopType', 'isTemporary',
                          'priceRange'])

    # Handle cuisine column
    df['cuisine'] = df['cuisine'].apply(lambda x: x[0] if isinstance(x, list) and x else None)

    # Handle categorical variables using one-hot encoding
    categorical_cols = ['city', 'category', 'typeEnt', 'cuisine']
    df = pd.get_dummies(df, columns=categorical_cols, dtype=float)

    return df, place_names

def model(id):
    db = firestore.client()
    places_ref = db.collection(u'ApprovedPlaces')
    places = [place.to_dict() for place in places_ref.stream()]

    # Preprocess the data
    encoded_data, place_names = preprocess_data(places)

    place1 = encoded_data.loc[encoded_data['place_id'] == id]

    encoded_data = encoded_data[encoded_data.place_id != id]

    nbrs = NearestNeighbors(n_neighbors=5).fit(encoded_data.drop(columns=['place_id']))
    distances, indices = nbrs.kneighbors(place1.drop(columns=['place_id']))

    similarity = [(1 - dist) * 100 for dist in distances[0]]

    recommend_item = []
    for i, index in enumerate(indices[0]):
        if similarity[i] >= 80:
            place_id_value = encoded_data.iloc[index]['place_id']
            distance_value = haversine_distance(place1['latitude'].values[0], place1['longitude'].values[0],
                                                encoded_data.iloc[index]['latitude'], encoded_data.iloc[index]['longitude'])
            place_name = place_names.get(place_id_value, 'Unknown')
            recommend_item.append({'place_id': place_id_value, 'place_name': place_name,
                                   'similarity_score': similarity[i], 'distance': distance_value})

    # Sort recommendations by distance in ascending order
    recommend_item.sort(key=lambda x: x['distance'])

    return json.dumps(recommend_item)

@app.route('/api', methods=['GET'])
def get_recommendations():
    place_id = str(request.args['query'])
    recommend_list = model(place_id)
    return recommend_list

if __name__ == "__main__":
    app.run(host="0.0.0.0")
