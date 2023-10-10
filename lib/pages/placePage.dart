class placePage {
  String placeId;
  String placeName;
  String userId;
  String category;
  String city;
  String neighborhood;
  List<String> images;
  String description;
  String Location;



  placePage({
    required this.placeId,
    required this.placeName,
    required this.userId,
    required this.category,
    required this.city,
    required this.neighborhood,
    required this.images,
    required this.description,
    required this.Location,
  });
  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'userId': userId,
      'placeName':placeName,
      'category': category,
      'city': city,
      'neighborhood': neighborhood,
      'images': images,
      'description': description,
      'Location': Location,

    };
  }

  factory placePage.fromMap(Map<String, dynamic> map) {
    return placePage(
      placeId: map['placeId'] ?? '',
      userId: map['userId'] ?? '',
      placeName: map['placeName'] ?? '',
      category: map['category'] ?? '',
      city: map['city'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      images: List.from(map['images']),
      Location: map['Location'] ?? '',
      description: map['description'] ?? '',
    );
  }
}



