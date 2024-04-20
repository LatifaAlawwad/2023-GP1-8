import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'AddedPlaces.dart'; // Import the AddPlacesMessagePage
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;


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
    userId = getuser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 110),
          child: Text(
            (widget.showConversation ? 'اختر يوم لإضافة المكان  ' : 'تخطيط الرحلات'),
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

      body: _buildTableCalendar(),

    );
  }

  Widget _buildTableCalendar() {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align widgets at top and bottom
        children: [
          SizedBox(height: 50),
          TableCalendar(
            // Your TableCalendar properties here
            firstDay: _firstDay,
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
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
              titleTextFormatter: (date, locale) {
                // Custom formatting for the header title (month name + year)
                final arabicMonthNames = [
                  'يناير',
                  'فبراير',
                  'مارس',
                  'ابريل',
                  'مايو',
                  'يونيو',
                  'يوليو',
                  'أغسطس',
                  'سبتمبر',
                  'أكتوبر',
                  'نوفمبر',
                  'ديسمبر',
                ];

                final monthName = arabicMonthNames[date.month - 1]; // Subtract 1 to match index
                final year = date.year.toString();

                return '$monthName $year'; // Combine month name and year
              },
            ),
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final arabicDays = {
                  DateTime.saturday: 'س', // Replace with your desired Arabic day names
                  DateTime.sunday: 'أ',
                  DateTime.monday: 'ن',
                  DateTime.tuesday: 'ث',
                  DateTime.wednesday: 'ب',
                  DateTime.thursday: 'خ',
                  DateTime.friday: 'ج',
                };

                final weekday = day.weekday;
                final arabicDayName = arabicDays[weekday];

                return Center(
                  // Adjust the bottom padding as needed
                  child: Text(
                    arabicDayName ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Tajawal-b',
                      color: const Color.fromARGB(255, 109, 184, 129), // Text color for days
                      fontWeight: FontWeight.bold, // Make the text bold
                    ),
                  ),
                );
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                });

                if (widget.showConversation) {
                  // Handle showing message conversation
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'تأكيد الإضافة',
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
                              text: '${widget.placeName} هل تريد إضافة \n',
                            ),
                            TextSpan(
                              text: '${DateFormat('yyyy-MM-dd').format(_selectedDay!)} لرحلتك في ',
                              style: TextStyle(
                                color: Color(0xff424242),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Align buttons in the center horizontally
                            children: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop(); // Close the dialog
                                  String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('calendar')
                                      .doc(widget.place_id!) // Access place_id from widget object
                                      .set({
                                    'SelectedDay': formattedDate,
                                    'place_id': widget.place_id,
                                  });
                                  // Show toast message
                                  Fluttertoast.showToast(
                                    msg: 'تمت إضافة المكان بنجاح',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                                child: Text('إضافة'),
                                style: TextButton.styleFrom(
                                  primary: Color(0xff11630e),
                                ),
                              ),
                              SizedBox(width: 16), // Add spacing between buttons if needed
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('إلغاء'),
                                style: TextButton.styleFrom(
                                  primary: Color(0xff11630e),
                                ),
                              ),
                            ],
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
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ],
      ),
    );
  }






  String getuser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var cpuid = user!.uid;
    return cpuid;
  }
}
