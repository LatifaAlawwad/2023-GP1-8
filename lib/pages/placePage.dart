class placePage {
  String place_id;
  String placeName;
  String userId;
  String category;
  String type1;
  String city;
  String neighbourhood;
  List<String> images;
  String description;
  String Location;
  bool? allowChildren; // New attribute
  double latitude;
  double longitude;
  placePage({
    required this.place_id,
    required this.placeName,
    required this.userId,
    required this.category,
    required this.type1,
    required this.city,
    required this.neighbourhood,
    required this.images,
    required this.description,
    required this.Location,
    required this.latitude,
    required this.longitude,


  // Include the new attribute
  });

  Map<String, dynamic> toMap() {
    return {
      'place_id': place_id,
      'userId': userId,
      'placeName': placeName,
      'category': category,
      'type1': type1,
      'city': city,
      'neighborhood': neighbourhood,
      'images': images,
      'description': description,
      'Location': Location,
      'allowChildren': allowChildren, // Include the new attribute
    };
  }

  factory placePage.fromMap(Map<String, dynamic> map) {
    return placePage(
      place_id: map['place_id'] ?? '',
      userId: map['userId'] ?? '',
      placeName: map['placeName'] ?? '',
      category: map['category'] ?? '',
      type1: map['type1'] ?? '',
      city: map['city'] ?? '',
      neighbourhood: map['neighbourhood'] ?? '',
      images: List<String>.from(map['images']),
      Location: map['Location'] ?? '',
      description: map['description'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
     // Parse the new attribute
    );
  }
}



