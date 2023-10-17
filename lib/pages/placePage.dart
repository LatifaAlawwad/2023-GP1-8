class placePage {
  String place_id;
  String placeName;
  String userId;
  String category;
  String type1;
  String city;
  String neighborhood;
  List<String> images;
  String description;
  String Location;

  placePage({
    required this.place_id,
    required this.placeName,
    required this.userId,
    required this.category,
    required this.type1,
    required this.city,
    required this.neighborhood,
    required this.images,
    required this.description,
    required this.Location,
  });

  Map<String, dynamic> toMap() {
    return {
      'place_id': place_id,
      'userId': userId,
      'placeName': placeName,
      'category': category,
      'type1': type1,
      'city': city,
      'neighborhood': neighborhood,
      'images': images,
      'description': description,
      'Location': Location,
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
        neighborhood: map['neighborhood'] ?? '',
        images: List<String>.from(map['images']),
        Location: map['Location'] ?? '',
        description: map['description'] ?? '',
       );
   }
}