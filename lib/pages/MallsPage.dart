import 'placePage.dart';

class Mall {
  final bool hasCinema;
  final bool hasPlayArea;
  final bool hasFoodCourt;
  final bool hasSupermarket;
  final String INorOUT;
  final String ShopType;
  final placePage place;

  Mall({
    required this.hasCinema,
    required this.hasPlayArea,
    required this.hasFoodCourt,
    required this.hasSupermarket,
    required this.INorOUT,
    required this.ShopType,
    required this.place,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasCinema': hasCinema,
      'hasPlayArea': hasPlayArea,
      'hasFoodCourt': hasFoodCourt,
      'hasSupermarket' : hasSupermarket,
      'INorOUT': INorOUT,
      'ShopType': ShopType,
      'place': place.toMap(),
    };
  }

  factory Mall.fromMap(Map<String, dynamic> map) {
    return Mall(
      hasCinema: map['hasCinema'] ?? false,
      hasPlayArea: map['hasPlayArea'] ?? false,
      hasFoodCourt: map['hasFoodCourt'] ?? false,
      hasSupermarket: map['hasSupermarket'] ?? false,
      ShopType: map['ShopType'] ?? '',
      INorOUT: map['INorOUT'] ?? '',
      place: placePage.fromMap(map),
    );
  }
}


