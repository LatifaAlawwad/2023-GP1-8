import 'placePage.dart';

class Mall {
  final bool hasCinema;
  final bool hasPlayArea;
  final bool hasFoodCourt;
  final bool hasSupermarket;
  final bool INorOUT;
  final placePage place;

  Mall({
    required this.hasCinema,
    required this.hasPlayArea,
    required this.hasFoodCourt,
    required this.hasSupermarket,
    required this.INorOUT,
    required this.place,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasCinema': hasCinema,
      'hasPlayArea': hasPlayArea,
      'hasFoodCourt': hasFoodCourt,
      'hasSupermarket' : hasSupermarket,
      'INorOUT': INorOUT,
      'place': place.toMap(),
    };
  }

  factory Mall.fromMap(Map<String, dynamic> map) {
    return Mall(
      hasCinema: map['hasCinema'] ?? false,
      hasPlayArea: map['hasPlayArea'] ?? false,
      hasFoodCourt: map['hasFoodCourt'] ?? false,
      hasSupermarket: map['hasSupermarket'] ?? false,
      INorOUT: map['INorOUT'] ?? false,
      place: placePage.fromMap(map),
    );
  }
}


