class Restaurant {
  final String cuisine;
  final String priceRange;
  final String serves;
  final String atmosphere;
  final bool? hasReservation;
  final bool? allowChildren;  // Change to bool?

  Restaurant({
    required this.cuisine,
    required this.priceRange,
    required this.serves,
    required this.atmosphere,
    this.hasReservation,
    this.allowChildren// Update the parameter type
  });

  Map<String, dynamic> toMap() {
    return {
      'cuisine': cuisine,
      'priceRange': priceRange,
      'serves': serves,
      'atmosphere': atmosphere,
      'hasReservation': hasReservation,
      'allowChildren':allowChildren,// Update the property type
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      cuisine: map['cuisine'] ?? '',
      priceRange: map['priceRange'] ?? '',
      serves: map['serves'] ?? '',
      atmosphere: map['atmosphere'] ?? '',
      hasReservation: map['hasReservation'],
        allowChildren:map['allowChildren'],
    );
  }
}

