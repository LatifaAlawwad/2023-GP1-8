import 'package:cloud_firestore/cloud_firestore.dart';

class Review{
  String id;
  String placeId;
  String userId;
  String userName;
  double rating;
  String comment;
  DateTime timestamp;

  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,

    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      placeId: map['placeId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: map['rating']?? 0,
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] ?? '',

    );
  }
}

