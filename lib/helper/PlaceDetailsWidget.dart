import 'package:flutter/material.dart';
import 'package:gp/helper/DayWidget.dart';
import 'package:gp/pages/placePage.dart';
import 'package:intl/intl.dart';

class PlaceDetailsWidget extends StatelessWidget {
  final placePage place;

  PlaceDetailsWidget({
    required this.place,
  });

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      DateTime date = DateTime.parse(dateString);
      String formattedDate = DateFormat('E d MMM hh:mm a').format(date);
      return formattedDate;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(place.toMap().toString());
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (place.address != null && place.address != '')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${place.address}'),
                SizedBox(
                  height: 4,
                ),
                Text(
                  ':عنوان المكان',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
          if (place.webLink != null && place.webLink != '')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${place.webLink}'),
                SizedBox(
                  height: 4,
                ),
                Text(
                  ':رابط موقع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ':وصف',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 4,
              ),
              Text('${place.description}')
            ],
          ),
          if (place.hasValetServiced != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(place.hasValetServiced ?? false ? 'نعم' : 'لا'),
                SizedBox(
                  width: 4,
                ),
                Text(
                  ':خدمة صف السيارات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          if (place.category == 'مطاعم') ...[
            if (place.cuisine != null && place.cuisine != '')
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ':مطبخ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text('${place.cuisine}')
                ],
              ),
            if (place.priceRange != null && place.priceRange != '')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${place.priceRange}'),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    ':نطاق السعر',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.serves != null && place.serves != '')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${place.serves}'),
                  SizedBox(width: 4,),
                  Text(
                    ':يخدم',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.atmosphere != null && place.atmosphere != '')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${place.atmosphere}'),
                  SizedBox(width: 4,),
                  Text(
                    ':أَجواء',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.allowChildren != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(place.allowChildren ?? false ? 'نعم' : 'لا'),
                  SizedBox(width: 4,),
                  Text(
                    ':السماح للأطفال',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
          if (place.category == 'مراكز تسوق') ...[
            if (place.hasCinema != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(place.hasCinema ?? false ? 'نعم' : 'لا'),
                  SizedBox(width: 4,),
                  Text(
                    ':بها سينما',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.INorOUT != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(place.INorOUT ?? false ? 'خارج' : 'داخل'),
                  SizedBox(width: 4,),
                  Text(
                    ':الجلوس في الداخل أو الخارج',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.hasFoodCourt != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(place.hasFoodCourt ?? false ? 'نعم' : 'لا'),
                  SizedBox(width: 4,),
                  Text(
                    ':لديه قاعة طعام',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.hasPlayArea != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(place.hasPlayArea ?? false ? 'نعم' : 'لا'),
                  SizedBox(width: 4,),
                  Text(
                    ':يوجد بها منطقة لعب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (place.hasSupermarket != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(place.hasSupermarket ?? false ? 'نعم' : 'لا'),
                  SizedBox(width: 4,),
                  Text(
                    ':يوجد سوبر ماركت',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
          if (place.category == 'فعاليات و ترفيه') ...[
            if (place.startDate != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${formatDate(place.startDate)}'),
                  SizedBox(width: 4,),
                  Text(
                    ' :تاريخ البدء',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            Text('Start Date: ${formatDate(place.startDate)}'),
            if (place.finishDate != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${formatDate(place.finishDate)}'),
                  SizedBox(width: 4,),
                  Text(
                    ' :تاريخ الانتهاء',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
          if (place.dayss != null && place.dayss!.length > 0)
            PlaceDays(
              place: place,
            )
        ],
      ),
    );
  }
}
