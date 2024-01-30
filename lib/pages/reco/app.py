from flask import Flask, jsonify, request
import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from sklearn.neighbors import NearestNeighbors
import json

app = Flask(__name__)

cred = credentials.Certificate("fir-hail-ec5a7-firebase-adminsdk-9d92w-d67984762b.json")
firebase_admin.initialize_app(cred)


def model(id):
    db = firestore.client()
    places = list(db.collection(u'ApprovedPlaces').stream())
    places_dict = list(map(lambda x: x.to_dict(), places))
    df = pd.DataFrame(places_dict)

    df = df.drop(columns=['placeName', 'User_id', 'images', 'description', 'allowChildren', 'latitude', 'longitude', 'WorkedDays',
                          'hasValetServiced', 'serves', 'atmosphere'])
    df = df.drop(columns=['hasCinema', 'hasFoodCourt', 'hasPlayArea', 'hasSupermarket', 'startDate','neighbourhood','finishDate', 'WebLink', 'hasReservation', 'reservationDetails', 'shopType', 'isTemporary'])

    df['cuisine'] = df['cuisine'].apply(lambda x: x[0] if isinstance(x, list) and x else None)

    df_copy = df.copy()
    encoded_data = pd.get_dummies(df_copy, columns=['city', 'category', 'priceRange','typeEnt','INorOUT','cuisine'])
    print("Columns in encoded_data:", encoded_data.columns)

    print("Columns in encoded_data:", encoded_data.columns)
    print("Type of id:", type(id))
    print("Unique values in 'place_id':", encoded_data['place_id'].unique())

    place1 = encoded_data.loc[encoded_data['place_id'] == id]

    encoded_data = encoded_data[encoded_data.place_id != id]

    nbrs = NearestNeighbors(n_neighbors=5).fit(encoded_data.drop(columns=['place_id']))
    distances, indices = nbrs.kneighbors(place1.drop(columns=['place_id']))

    distance = distances[0]
    similarity = [(1 - dist) * 100 for dist in distance if dist is not None]

    recommend_item = []
    index = 0
    for i in indices:
        for place_id_value in encoded_data.iloc[i]['place_id']:
            if similarity[index] >= 80:
                print(similarity[index])
                recommend_item.append(place_id_value)
            index += 1

    return json.dumps(recommend_item)

@app.route('/api', methods=['GET'])
def get_recommendations():
    place_id = str(request.args['query'])
    recommend_list = model(place_id)
    return recommend_list

if __name__ == "__main__":
    app.run(host="0.0.0.0")

