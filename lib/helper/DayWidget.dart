import 'package:flutter/material.dart';
import 'package:gp/pages/placePage.dart';

class DayWidget extends StatelessWidget {
  final Map<String, dynamic> dayData;

  DayWidget(this.dayData);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day: ${dayData["day"]}'),
        Text('Opening Time: ${dayData["وقت الإفتتاح"]}'),
        Text('Closing Time: ${dayData["وقت الإغلاق"]}'),
        // Add any other properties you want to display
      ],
    );
  }
}

class PlaceDays extends StatelessWidget {
  final placePage place; // Assuming you have a Place class with a dayss property

  PlaceDays({required this.place});

  @override
  Widget build(BuildContext context) {
    List<Widget> dayWidgets = [];

    if (place.dayss != null && place.dayss!.length > 0) {
      for (var dayData in place.dayss!) {
        DayWidget dayWidget = DayWidget(dayData as Map<String, dynamic>);
        dayWidgets.add(dayWidget);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.placeName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Other place details widgets
            Text('Working Days:'),
            Column(children: dayWidgets),
          ],
        ),
      ),
    );
  }
}