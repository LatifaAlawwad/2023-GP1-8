from flask import Flask, request, jsonify
from firebase_admin import credentials, firestore, initialize_app
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
import re

app = Flask(__name__)
stops = {"و", "في", "من", "على", "إلى", "عن", "هذا", "هذه", "هنا", "هناك"}  # Add more stopwords as needed

# Initialize Firebase
cred = credentials.Certificate("fir-hail-ec5a7-firebase-adminsdk-9d92w-d67984762b.json")
initialize_app(cred)
db = firestore.client()


# Function to fetch user data from Firestore
def fetch_user_data(user_id):
    favorites_ref = db.collection('users').document(user_id).collection('Favorite')
    preferences_ref = db.collection('users').document(user_id).collection('prefrences')

    try:
        favorites = [favorite.to_dict() for favorite in favorites_ref.stream()]
        preferences = [preference.to_dict() for preference in preferences_ref.stream()]
    except Exception as e:
        print("Error fetching user data:", e)
        favorites = []
        preferences = []

    return favorites, preferences


# Function to fetch approved places from Firestore
def fetch_approved_places(city_name=None):
    places_ref = db.collection('ApprovedPlaces')
    places = [place.to_dict() for place in places_ref.stream()]

    if city_name:
        places = [place for place in places if place.get('city', '') == city_name]

    return places


# Preprocess data
def preprocess_data(approved_places):
    item_profiles = {}
    for place in approved_places:
        place_id = place['place_id']
        # Retrieve attributes with default values if they are missing
        category = place.get('category', '')
        city = str(place.get('city', ''))  # Convert to string
        cuisine = str(place.get('cuisine', ''))  # Convert to string
        type_entertainment = str(place.get('typeEnt', ''))  # Convert to string
        serves = str(place.get('serves', ''))  # Convert to string
        atmosphere = str(place.get('atmosphere', ''))  # Convert to string
        shop_type = str(place.get('shopType', ''))

        # Concatenate attributes into a single string
        text = ' '.join([category, city, cuisine, serves, atmosphere,
                         shop_type, type_entertainment])
        # Preprocess text
        preprocessed_text = preprocess_text(text)
        item_profiles[place_id] = preprocessed_text

    return item_profiles


# Preprocess text
def preprocess_text(text):
    # Tokenize Arabic text
    tokens = text.split()

    # Remove non-Arabic characters and punctuation
    arabic_only = [re.sub(r'[^\u0621-\u064A\s]', '', token) for token in tokens]

    # Convert to lowercase
    lowercase_tokens = [token.lower() for token in arabic_only]

    # Remove stopwords
    cleaned_tokens = [token for token in lowercase_tokens if token not in stops and len(token) >= 2]

    # Join tokens back into text
    preprocessed_text = ' '.join(cleaned_tokens)

    return preprocessed_text


# Function to get place name
def get_place_name(approved_places, place_id, city_name):
    for place in approved_places:
        if place['place_id'] == place_id and place.get('city', '') == city_name:
            # Retrieve attributes with default values if they are missing
            place_name = place.get('placeName', '')
            return place_name
    return "Unknown"


# Function to preprocess user preferences
def preprocess_preferences(preferences):
    preference_profiles = {}
    for preference in preferences:
        place_id = preference['place_id']
        # Retrieve attributes with default values if they are missing
        category = preference.get('category', '')
        city = str(preference.get('city', ''))  # Convert to string
        cuisine = str(preference.get('cuisine', ''))  # Convert to string
        type_entertainment = str(preference.get('typeEnt', ''))  # Convert to string
        serves = str(preference.get('serves', ''))  # Convert to string
        atmosphere = str(preference.get('atmosphere', ''))  # Convert to string
        shop_type = str(preference.get('shopType', ''))

        # Concatenate attributes into a single string
        text = ' '.join([category, city, cuisine, serves, atmosphere,
                         shop_type, type_entertainment])
        # Preprocess text
        preprocessed_text = preprocess_text(text)
        preference_profiles[place_id] = preprocessed_text

    return preference_profiles


# Function to recommend places based on item similarity
def model(user_favorites, preference_profiles, item_profiles):
    recommendations = set()

    if user_favorites:  # If favorites are found
        # Limit favorites to first 300 places if more than 300
        if len(user_favorites) > 300:
            user_favorites = user_favorites[:300]

        for favorite in user_favorites:
            place_id = favorite['place_id']
            if place_id in item_profiles:
                tfidf_vectorizer = TfidfVectorizer()
                tfidf_matrix = tfidf_vectorizer.fit_transform([item_profiles[place_id], *item_profiles.values()])
                cosine_similarities = linear_kernel(tfidf_matrix[0:1], tfidf_matrix[1:]).flatten()
                similar_indices = cosine_similarities.argsort()[:-6:-1]  # Get top 5 similar items
                similar_items = [(list(item_profiles.keys())[i], cosine_similarities[i]) for i in similar_indices]
                recommendations.update(similar_items)

    else:  # If favorites are not found, use preferences
        print("No favorites found. Using preferences instead.")
        for preference in preference_profiles:
            place_id = preference
            print("Processing preference for place:", place_id)
            if place_id in preference_profiles:
                tfidf_vectorizer = TfidfVectorizer()
                tfidf_matrix = tfidf_vectorizer.fit_transform([preference_profiles[place_id], *item_profiles.values()])
                cosine_similarities = linear_kernel(tfidf_matrix[0:1], tfidf_matrix[1:]).flatten()
                similar_indices = cosine_similarities.argsort()[:-6:-1]  # Get top 5 similar items
                similar_items = [(list(item_profiles.keys())[i], cosine_similarities[i]) for i in similar_indices]
                recommendations.update(similar_items)

    # Filter out places that are already in favorites or preferences
    recommendations = [(place_id, score) for place_id, score in recommendations if place_id not in [fav['place_id'] for fav in user_favorites] and place_id not in preference_profiles]

    return list(recommendations)


# Endpoint to get recommendations
@app.route('/api', methods=['GET'])
def get_recommendations():
    user_id = request.args.get('user_id')
    city_name = request.args.get('city_name')  # Added city_name parameter
    user_favorites, user_preferences = fetch_user_data(user_id)
    print("User favorites:", user_favorites)
    print("User preferences:", user_preferences)
    approved_places = fetch_approved_places(city_name)
    item_profiles = preprocess_data(approved_places)
    preference_profiles = preprocess_preferences(user_preferences)
    recommendations = model(user_favorites, preference_profiles, item_profiles)

    # Sort recommendations based on score (second element in each recommendation tuple)
    recommendations.sort(key=lambda x: x[1], reverse=True)

    # Create a list of dictionaries containing place_id, place_name, and score
    recommended_places = []
    recommended_ids = set()  # Set to keep track of recommended place IDs
    for rec in recommendations:
        place_id = rec[0]
        if place_id not in recommended_ids:  # Check if the place ID is not already in the set
            score = rec[1]
            placename = get_place_name(approved_places, place_id, city_name)
            recommended_places.append({'place_id': place_id, 'place_name': placename, 'score': score})
            recommended_ids.add(place_id)  # Add the place ID to the set of recommended IDs

    return jsonify({'api': recommended_places})


if __name__ == '__main__':
    app.run(debug=True)