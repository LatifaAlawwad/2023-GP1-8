import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gp/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'AddedPlaces.dart'; // Import the AddPlacesMessagePage
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;
import 'package:gp/Registration/logIn.dart';

class TripPlanningPage extends StatefulWidget {
  final DateTime? selectedDay;
  final bool showConversation;
  final String? place_id;
  final String? placeName;

  const TripPlanningPage({Key? key, this.selectedDay, this.showConversation = false, this.place_id, this.placeName}) : super(key: key);

  @override
  State<TripPlanningPage> createState() => _TripPlanningPageState();
}

class _TripPlanningPageState extends State<TripPlanningPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _firstDay = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDay = DateTime.now().add(Duration(days: 365));

  late String userId;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 110),
          child: Text(
            (widget.showConversation ? translation(context).chooseDay : translation(context).plans),
            style: TextStyle(
              fontSize: 17,
              fontFamily: "Tajawal-b",
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
        toolbarHeight: 60,
      ),
      body: Center(
        child: currentUser != null ? _buildTableCalendar() : _buildLoginWidget(context),
      ),
    );
  }

  Widget _buildLoginWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 79),
            child: Text(
              translation(context).reqLogin,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6db881),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogIn()),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF6db881)),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
            ),
            child: Text(
              translation(context).login,
              style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTableCalendar() {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 365));
    // Determine the first day based on showConversation condition
   DateTime firstDay = widget.showConversation ? today : yesterday;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          TableCalendar(
            firstDay: firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: {
              CalendarFormat.month: 'Month',
            },
            locale: 'en_US',
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarStyle: CalendarStyle(
              // Weekday text style
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 197, 241, 207), // Color for today
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color.fromARGB(255, 109, 184, 129), // Color for selected day
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(fontSize: 20),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: widget.showConversation ? Colors.transparent : Colors.black, // Grey color for the previous arrow based on showConversation
              ),
              rightChevronIcon: Icon(Icons.chevron_right),
              titleTextFormatter: (date, locale) {
                final arabicMonthNames = [
                  translation(context).jan,
                  translation(context).feb,
                  translation(context).march,
                  translation(context).april,
                  translation(context).may,
                  translation(context).june,
                  translation(context).july,
                  translation(context).aug,
                  translation(context).sep,
                  translation(context).oct,
                  translation(context).nov,
                  translation(context).dec,

                ];
                final monthName = arabicMonthNames[date.month - 1];
                final year = date.year.toString();
                return '$monthName $year';
              },
            ),

            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final arabicDays = {
                  DateTime.saturday: translation(context).sat,
                  DateTime.sunday: translation(context).sun,
                  DateTime.monday: translation(context).mon,
                  DateTime.tuesday: translation(context).tue,
                  DateTime.wednesday: translation(context).wed,
                  DateTime.thursday: translation(context).thu,
                  DateTime.friday: translation(context).fri,
                };
                final weekday = day.weekday;
                final arabicDayName = arabicDays[weekday];
                return Center(
                  child: Text(
                    arabicDayName ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Tajawal-b',
                      // Weekday text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              if (widget.showConversation) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      translation(context).conAdd,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff383737),
                      ),
                    ),
                    content: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Color(0xff383737),
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                              text: ('${widget.placeName} ${translation(context).wantToAdd} \n')
                          ),
                          TextSpan(
                              text:('${DateFormat('yyyy-MM-dd').format(_selectedDay!)} ${translation(context).yourTrip} '),
                            style: TextStyle(
                              color: Color(0xff424242),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          final currentDate = DateTime.now();
                          if (_selectedDay!.isBefore(currentDate)) {
                            Fluttertoast.showToast(
                              msg: translation(context).cantAdd,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: const Color.fromARGB(255, 109, 184, 129),
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } else {
                            String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
                            bool placeAlreadyAdded = await checkIfPlaceAlreadyAdded(formattedDate);
                            if (placeAlreadyAdded) {
                              Fluttertoast.showToast(
                                msg: translation(context).existedPlace,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: const Color.fromARGB(255, 109, 184, 129),
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('calendar')
                                  .doc(widget.place_id!)
                                  .set({
                                'SelectedDay': formattedDate,
                                'place_id': widget.place_id,
                              });
                              Fluttertoast.showToast(
                                msg: translation(context).succAdded,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                        },
                        child: Text(translation(context).add),
                        style: TextButton.styleFrom(
                          primary: Color(0xff11630e),
                        ),
                      ),
                      SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text(translation(context).cancel),
                        style: TextButton.styleFrom(
                          primary: Color(0xff11630e),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPlacesMessagePage(selectedDay: _selectedDay!)),
                );
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // Don't update _focusedDay here to avoid changing the focused day unexpectedly
            },
          ),
        ],
      ),
    );
  }



  Future<bool> checkIfPlaceAlreadyAdded(String formattedDate) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('calendar')
        .where('SelectedDay', isEqualTo: formattedDate)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> getUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

}

