import 'package:flutter/material.dart';
import 'package:gp/helper/DayWidget.dart';
import 'package:gp/helper/showBoolAttributes.dart';

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

  Widget _buildCard(String value) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF6db881),
          width: 1,
        ),
      ),
      child: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(place.toMap().toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (place.WebLink != '')
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 5,
              ),
              const Text(
                ':رابط موقع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Tajawal-m",
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                '${place.WebLink}',
                textAlign: TextAlign.right,
              ),
            ],
          ),
        if (place.category == 'مطاعم') ...[
          if (place.cuisine.length > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  ':مطبخ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 3,
                  children: place.cuisine.map((e) => _buildCard(e)).toList(),
                )
              ],
            ),
          if (place.priceRange != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${place.priceRange}',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  ':نطاق السعر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          if (place.serves.length > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  ':يخدم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 3,
                  children: place.serves.map((e) => _buildCard(e)).toList(),
                )
              ],
            ),

          if (place.atmosphere.length > 0) ...[
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  ':أَجواء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 3,
                  children: place.atmosphere.map((e) => _buildCard(e)).toList(),
                )
              ],
            ),
          ],
        ],
        Divider(),
        ShowBoolAttributesWidget(
            text: 'السماح للأطفال', check: place.allowChildren),
        ShowBoolAttributesWidget(
            text: 'خدمة صف السيارات', check: place.hasValetServiced),
        if (place.category == 'مراكز تسوق')
          Wrap(alignment: WrapAlignment.end, spacing: 3, children: [
            ShowBoolAttributesWidget(text: 'بها سينما', check: place.hasCinema),
            ShowBoolAttributesWidget(
                text: place.INorOUT
                    ? 'الجلوس في الداخل أو الخارج : خارج'
                    : 'الجلوس في الداخل أو الخارج : داخل',
                check: place.INorOUT),
            ShowBoolAttributesWidget(
                text: 'لديه قاعة طعام', check: place.hasFoodCourt),
            ShowBoolAttributesWidget(
                text: 'يوجد بها منطقة لعب', check: place.hasPlayArea),
            ShowBoolAttributesWidget(
                text: 'يوجد سوبر ماركت', check: place.hasSupermarket),

          ]),
        Divider(),
        if (place.category == 'فعاليات و ترفيه') ...[
          if (place.startDate != '') ...[
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${formatDate(place.startDate)}',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  ' :تاريخ البدء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                ),
              ],
            ),
          ],
          if (place.finishDate != '') ...[
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${formatDate(place.finishDate)}',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  ' :تاريخ الانتهاء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                ),
              ],
            ),
          ]
        ],
        if (place.workedDays.length > 0)
          PlaceDays(
            place: place,
          )
      ],
    );
  }
}
