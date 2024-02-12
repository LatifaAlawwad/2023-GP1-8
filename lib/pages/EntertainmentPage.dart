import 'placePage.dart';

class Entertainment {
  final String typeEnt;
  final bool isTemporary;
  final String startDate;
  final String finishDate;
  final String isOutdoor;

  Entertainment({
    required this.typeEnt,
    required this.isTemporary,
    required this.startDate,
    required this.finishDate,
    required this.isOutdoor,
  });

  Map<String, dynamic> toMap() {
    return {
      'typeEnt': typeEnt, // Modified field name
      'isTemporary': isTemporary,
      'startDate': startDate,
      'finishDate': finishDate,
      'isOutdoor': isOutdoor,
    };
  }

  factory Entertainment.fromMap(Map<String, dynamic> map) {
    return Entertainment(
      typeEnt: map['typeEnt'] ?? '', // Modified field name
      isTemporary: map['isTemporary'] ?? false,
      startDate: map['startDate'] ?? '',
      finishDate: map['finishDate'] ?? '',
      isOutdoor: map['isOutdoor'] ?? '',
    );
  }
}
