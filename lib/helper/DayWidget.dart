import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:gp/pages/placePage.dart';
import 'package:gp/language_constants.dart';
class DayWidget extends StatelessWidget {
  final Map<String, dynamic> dayData;
final String day;
  DayWidget(this.dayData, this.day);

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
               day ,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Tajawal-m",
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              dayData["وقت الإغلاق"] == '0'
                  ?  Text(
                translation(context).close,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Tajawal-m",
                ),
              )
                  : dayData["وقت الإغلاق"] == '12:59 PM' &&
                  dayData["وقت الإفتتاح"] == '00:00 AM'
                  ?  Text(
                translation(context).twentyfourHRS,
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
                         translation(context).closeHRS,
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
                          translation(context).openHRS,
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
      translation(context).sunday,
      translation(context).monday,
      translation(context).tuesday,
      translation(context).wednesday,
      translation(context).thursday,
      translation(context).friday,
      translation(context).saturday,
    ];


    List<String> dayss = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الإربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];


    for (var i = 0; i < dayss.length; i++)  {
      var day=dayss[i];
      if (place.workedDays
          .where((element) => element['day'] == day)
          .isNotEmpty) {
        DayWidget dayWidget = DayWidget(place.workedDays[
        place.workedDays.indexWhere((element) => element['day'] == day)]
        as Map<String, dynamic>, days[i]);

        dayWidgets.add(dayWidget);
      } else {
        DayWidget dayWidget = DayWidget({
          "day": day,
          "وقت الإغلاق": '0',
          "وقت الإفتتاح": '0'
        } as Map<String, dynamic>, days[i]);
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
          header:  Padding(
            padding: EdgeInsets.all(10),
            child: Text(
                  translation(context).workingHRS,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: Localizations.localeOf(context).languageCode == 'ar' ? TextAlign.right : TextAlign.left,

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
               // const Divider(),

                const Divider(),
                Column(children: dayWidgets),
              ],
            ),
          )),
    );
  }
}
