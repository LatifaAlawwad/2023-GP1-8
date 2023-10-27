/*import 'placePage.dart';

class Entertainment {
  final String type;
  final bool isTemporary;
  final String startDate;
  final String finishDate;
  final bool isOutdoor;
  final placePage place;

  Entertainment({
    required this.type,
    required this.isTemporary,
    required this.startDate,
    required this.finishDate,
    required this.isOutdoor,
    required this.place,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'isTemporary': isTemporary,
      'startDate': startDate,
      'finishDate': finishDate,
      'isOutdoor': isOutdoor,
      'place': place.toMap(),
    };
  }

  factory Entertainment.fromMap(Map<String, dynamic> map) {
    return Entertainment(
      type: map['type'] ?? '',
      isTemporary: map['isTemporary'] ?? false,
      startDate: map['startDate'] ?? '',
      finishDate: map['finishDate'] ?? '',
      isOutdoor: map['isOutdoor'] ?? false,
      place: placePage.fromMap(map),
    );
  }
}
*/