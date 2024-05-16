import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gp/language_constants.dart';

class Review extends StatelessWidget {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final double rating;
  final String text;
  final String timestamp;
  final bool currentUserReview;
  final Function onDelete;
  final Function onUpdate;

  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    required this.timestamp,
    required this.currentUserReview,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                timestamp,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,                        mainAxisAlignment: isArabic()? MainAxisAlignment.start:MainAxisAlignment.end,

            children: [
              Row(
                children: List.generate(
                  5,
                      (index) => Padding(
                    padding: EdgeInsets.only(right: 1.0, bottom: 5.0),
                    child: Icon(
                      index >= rating ? Icons.star_border : Icons.star,
                      size: 17,
                      color: const Color.fromARGB(
                          255, 109, 184, 129), // Green color for the edges
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // This row contains the text and the three dots
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),

                    ),
                    if (currentUserReview)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'update',
                            child: Text(translation(context).update),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(translation(context).delete),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'update') {
                            onUpdate();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },

                      ),

                  ],
                ),
              ),
            ],
          ),
        ],
      ),


    );

  }
}
