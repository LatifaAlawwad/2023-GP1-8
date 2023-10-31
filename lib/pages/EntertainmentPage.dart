import 'placePage.dart';

class Entertainment {
  final String typeEnt;
  final bool isTemporary;
  final String startDate;
  final String finishDate;
  final bool isOutdoor;
  final placePage place;
  final bool? hasValet;

  Entertainment({
    required this.typeEnt,
    required this.isTemporary,
    required this.startDate,
    required this.finishDate,
    required this.isOutdoor,
    required this.place,
    this.hasValet,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': typeEnt,
      'isTemporary': isTemporary,
      'startDate': startDate,
      'finishDate': finishDate,
      'isOutdoor': isOutdoor,
      'place': place.toMap(),
      'hasValet' : hasValet,
    };
  }

  factory Entertainment.fromMap(Map<String, dynamic> map) {
    return Entertainment(
      typeEnt: map['type'] ?? '',
      isTemporary: map['isTemporary'] ?? false,
      startDate: map['startDate'] ?? '',
      finishDate: map['finishDate'] ?? '',
      isOutdoor: map['isOutdoor'] ?? false,
      place: placePage.fromMap(map),
      hasValet: map['hasValet'],
    );
  }
}
