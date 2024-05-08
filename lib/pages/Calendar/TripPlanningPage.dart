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
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
              titleTextFormatter: (date, locale) {
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
                final monthName = arabicMonthNames[date.month - 1];
                final year = date.year.toString();
                return '$monthName $year';
              },
            ),
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final arabicDays = {
                  DateTime.saturday: 'س',
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
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle().copyWith(color: Colors.black), // Hide weekends
              weekdayStyle: TextStyle().copyWith(color: Colors.black), // Show weekdays
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
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          final currentDate = DateTime.now();
                          if (_selectedDay!.isBefore(currentDate)) {
                            Fluttertoast.showToast(
                              msg: 'لا يمكنك إضافة المكان لتاريخ سابق',
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
                                msg: 'المكان مضاف بالفعل في هذا التاريخ',
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
                                msg: 'تمت إضافة المكان بنجاح',
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
                        child: Text('إضافة'),
                        style: TextButton.styleFrom(
                          primary: Color(0xff11630e),
                        ),
                      ),
                      SizedBox(width: 16),
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

  String getuser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var cpuid = user!.uid;
    return cpuid;
  }
}

