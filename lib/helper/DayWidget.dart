import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:gp/pages/placePage.dart';

class DayWidget extends StatelessWidget {
  final Map<String, dynamic> dayData;

  DayWidget(this.dayData);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'يوم:${dayData["day"]}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Tajawal-m",
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              dayData["وقت الإغلاق"] == '0'
                  ? const Text(
                'مغلق',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Tajawal-m",
                ),
              )
                  : dayData["وقت الإغلاق"] == '12:59 PM' &&
                  dayData["وقت الإفتتاح"] == '00:00 AM'
                  ? const Text(
                'مفتوحة 24 ساعة',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Tajawal-m",
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "وقت الإغلاق",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w700,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          dayData["وقت الإغلاق"],
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: "Tajawal-m",
                          ),
                        )
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "وقت الإفتتاح",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w700,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          dayData["وقت الإفتتاح"],
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: "Tajawal-m",
                          ),
                        )
                      ]),
                ],
              ),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}

class PlaceDays extends StatelessWidget {
  final placePage
  place; // Assuming you have a Place class with a dayss property

  PlaceDays({required this.place});

  @override
  Widget build(BuildContext context) {
    List<Widget> dayWidgets = [];
    List<String> days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الإربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];

    for (var day in days) {
      if (place.workedDays
          .where((element) => element['day'] == day)
          .isNotEmpty) {
        DayWidget dayWidget = DayWidget(place.workedDays[
        place.workedDays.indexWhere((element) => element['day'] == day)]
        as Map<String, dynamic>);
        dayWidgets.add(dayWidget);
      } else {
        DayWidget dayWidget = DayWidget({
          "day": day,
          "وقت الإغلاق": '0',
          "وقت الإفتتاح": '0'
        } as Map<String, dynamic>);
        dayWidgets.add(dayWidget);
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF6db881),
          width: 1,
        ),
      ),
      child: ExpandablePanel(
          collapsed: const SizedBox(),
          header: const Padding(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'أيام الافتتاح ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          theme: const ExpandableThemeData(
              tapBodyToCollapse: true,

              iconColor: Color(0xFF6db881),
              iconPlacement: ExpandablePanelIconPlacement.left),
          expanded: Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const Text(
                  'أيام الافتتاح ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                Column(children: dayWidgets),
              ],
            ),
          )),
    );
  }
}
