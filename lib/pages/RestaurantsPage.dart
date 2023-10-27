/*import 'placePage.dart';

class Restaurant {
  final String cuisine;
  final String priceRange;
  final String serves;
  final String atmosphere;
  final bool hasReservation;
  final bool allowChildren;
  final placePage place;

  Restaurant({
    required this.cuisine,
    required this.priceRange,
    required this.serves,
    required this.atmosphere,
    required this.hasReservation,
    required this.allowChildren,
    required this.place,
  });

  Map<String, dynamic> toMap() {
    return {
      'cuisine': cuisine,
      'priceRange': priceRange,
      'serves': serves,
      'atmosphere': atmosphere,
      'hasReservation': hasReservation,
      'allowChildren': allowChildren,
      'place': place.toMap(),
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      cuisine: map['cuisine'] ?? '',
      priceRange: map['priceRange'] ?? '',
      serves: map['serves'] ?? '',
      atmosphere: map['atmosphere'] ?? '',
      hasReservation: map['hasReservation'] ?? false,
      allowChildren: map['allowChildren'] ?? false,
      place: placePage.fromMap(map),
    );
  }
}*/
