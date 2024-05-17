import 'dart:async';
import 'dart:io';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:gp/Registration/logIn.dart';
import 'package:gp/helper/CustomRadioButton.dart';
import 'package:gp/helper/MapViewDrop.dart';
import 'package:gp/language_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'HomePage.dart';
import 'cities.dart';
import 'neighbourhood.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

  static const appTitle = 'إضافة مكان';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0,right:10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Text(
              translation(context).addPlace,
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Tajawal-b",
              ),
            ),
            SizedBox(width: 40), // Adjust the width based on your preference
          ],
        ),
        centerTitle: false,

      ),
      body: FirebaseAuth.instance.currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 79),
                    child: Text(
                      translation(context).reqLogin,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Tajawal-b",
                        color: Color(0xFF6db881),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LogIn()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF6db881)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
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
            )
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ClipPath(
                      clipper: MyCustomClipper(),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        color: const Color(0xFF6db881),
                      ),
                    )
                  ],
                ),
                const CustomForm()
              ],
            ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height / 3)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomForm extends StatefulWidget {
  const CustomForm({Key? key});

  @override
  CustomFormState createState() {
    return CustomFormState();
  }
}

class CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  int type = 0;
  String? type1;
  String place_id = '';
  String city = "الرياض";
  String? address;
  final WebLink = TextEditingController();
  final description = TextEditingController();
  final placeName = TextEditingController();
  DateTime startDateDateTime = DateTime.now();

  List<Map<String, String>> workingHoursList = [];

  //for the location
  static final TextEditingController _startSearchFieldController =
      TextEditingController();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  bool isLoadingPlaces = false;
  Timer? _debounce;
  var startPosition = null;

  final GlobalKey<FormFieldState> _AddressKey = GlobalKey<FormFieldState>();
  bool? hasValetServiced;

  bool? allowChildren;
  String isOutdoor = "";

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyAMZ84MvLuQMMAQBSVFYZ8fGgb5oYqqCn4');
  }

  //for rest
  List<String> userChecked = [];
  List<String> cuisine = [];

  bool? isTemporary;
  String startDate = '';
  String finishDate = '';
  String INorOUT = '';

  bool? hasCinema;
  bool? hasPlayArea;
  bool? hasFoodCourt;
  bool? hasSupermarket;
  String reservationDetails = '';
  String typeEnt = '';

  void autoCompleteSearch(String value) async {
    setState(() {
      isLoadingPlaces = true;
      startPosition = null;
    });
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
    setState(() {
      isLoadingPlaces = false;
    });
  }

  void _onSelected(bool selected, String day) {
    if (selected == true) {
      setState(() {
        userChecked.add(day);
        if (dayss.where((element) => element['day'] == day).isEmpty)
          dayss.add(
              {"day": day, "وقت الإغلاق": closeAt, "وقت الإفتتاح": openAt});
      });
      print(closeAt);
      print(openAt);
      print(dayss);
    } else {
      setState(() {
        userChecked.remove(day);
        dayss.removeWhere((element) => element['day'] == day);
      });
    }
  }

  void _onSelected24(bool selected, String day) {
    dayss.removeWhere((element) => element['day'] == day);
    if (selected == true) {
      setState(() {
        dayss.add({
          "day": day,
          "وقت الإغلاق": '12:59 PM',
          "وقت الإفتتاح": '00:00 AM'
        });
      });
      print(closeAt);
      print(openAt);
      print(dayss);
    } else {
      setState(() {
        dayss.add({"day": day, "وقت الإغلاق": closeAt, "وقت الإفتتاح": openAt});
      });
    }
  }

  bool is24HourOpen(String openAt, String closeAt) {
    // Check if the difference is exactly 24 hours
    return openAt == '00:00 AM' && closeAt == '12:59 PM';
  }

  String openAt = "09:00 AM";
  String closeAt = "05:00 PM";
  List<Map<String, dynamic>> dayss = [];

  Future<void> showWorkingHoursDialog(BuildContext context) async {
    List<String> days = [
      translation(context).sunday,
      translation(context).monday,
      translation(context).tuesday,
      translation(context).wednesday,
      translation(context).thursday,
      translation(context).friday,
      translation(context).saturday,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFF6db881)),
              borderRadius: BorderRadius.circular(8),
            ),
            title: Center(
                child: Text(
              translation(context).selectWorkinghrs,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: days.map((day) {
                  String openHours = dayss
                          .where((element) => element['day'] == day)
                          .isNotEmpty
                      ? dayss[dayss.indexWhere(
                          (element) => element['day'] == day)]['وقت الإفتتاح']
                      : openAt;
                  String closeHours = dayss
                          .where((element) => element['day'] == day)
                          .isNotEmpty
                      ? dayss[dayss.indexWhere(
                          (element) => element['day'] == day)]['وقت الإغلاق']
                      : closeAt;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isArabic()? CrossAxisAlignment.end :CrossAxisAlignment.start,
                        children: [
                          ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: Transform.scale(
                                scale: 0.8,
                                //open/close
                                child: CupertinoSwitch(
                                    value: userChecked.contains(day),
                                    activeColor: const Color(0xFF6db881),
                                    onChanged: (bool value) {
                                      print(value.toString());
                                      setState(() {
                                        _onSelected(value!, day);
                                        print(userChecked.toString());
                                      });
                                    }),
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  day,
                                  textAlign: TextAlign.end,
                                ),
                              )),
                          if (userChecked.contains(day))
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                          value: is24HourOpen(
                                              openHours, closeHours),
                                          activeColor: const Color(0xFF6db881),
                                          onChanged: (bool value) {
                                            print(value.toString());
                                            setState(() {
                                              _onSelected24(value!, day);
                                              print(userChecked.toString());
                                            });
                                          }),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                          translation(context).twentyfourHRS),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              translation(context).closeHRS,
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                BottomPicker.time(
                                                  title:
                                                      '${translation(context).closeHRS} $day',
                                                  titleStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF6db881)),
                                                  onChange: (value) {
                                                    String newValue =
                                                        DateFormat('hh:mm a')
                                                            .format(value!);
                                                    // setState(() {
                                                    //   closeAt = newValue;
                                                    // });
                                                    if (userChecked
                                                        .contains(
                                                            day)) if (dayss
                                                        .where((element) =>
                                                            element['day'] ==
                                                            day)
                                                        .isEmpty) {
                                                      dayss.add({
                                                        "day": day,
                                                        "وقت الإغلاق": newValue,
                                                        "وقت الإفتتاح": openAt
                                                      });
                                                    } else {
                                                      var prevDay = dayss[
                                                          dayss.indexWhere(
                                                              (element) =>
                                                                  element[
                                                                      'day'] ==
                                                                  day)];
                                                      dayss.removeWhere(
                                                          (element) =>
                                                              element['day'] ==
                                                              day);
                                                      dayss.add({
                                                        "day": day,
                                                        "وقت الإغلاق": newValue,
                                                        "وقت الإفتتاح": prevDay[
                                                            "وقت الإفتتاح"]
                                                      });
                                                    }
                                                    setState(() {});
                                                  },
                                                  buttonWidth: 80,
                                                  titleAlignment:
                                                      CrossAxisAlignment.center,
                                                  buttonSingleColor:
                                                      const Color(0xFF6db881),
                                                  displayButtonIcon: false,
                                                  buttonTextStyle:
                                                      const TextStyle(
                                                          fontSize: 17),
                                                  buttonText:
                                                      translation(context).save,
                                                  use24hFormat: false,
                                                  minuteInterval: 15,
                                                  initialTime: Time(
                                                    minutes: 0,
                                                  ),
                                                  pickerTextStyle:
                                                      const TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.black),
                                                ).show(context);
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          width: 1,
                                                          color: Colors.black),
                                                    )),
                                                child: Text(
                                                  dayss
                                                          .where((element) =>
                                                              element['day'] ==
                                                              day)
                                                          .isNotEmpty
                                                      ? dayss[dayss.indexWhere(
                                                              (element) =>
                                                                  element[
                                                                      'day'] ==
                                                                  day)]
                                                          ['وقت الإغلاق']
                                                      : closeAt,
                                                  style: const TextStyle(
                                                      fontSize: 25),
                                                ),
                                              ),
                                            )
                                          ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              translation(context).openHRS,
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                BottomPicker.time(
                                                  title:
                                                      '${translation(context).openHRS} $day',
                                                  titleStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF6db881)),
                                                  onChange: (value) {
                                                    String newValue =
                                                        DateFormat('hh:mm a')
                                                            .format(value!);
                                                    // setState(() {
                                                    //   openAt = newValue;
                                                    // });
                                                    if (userChecked
                                                        .contains(
                                                            day)) if (dayss
                                                        .where((element) =>
                                                            element['day'] ==
                                                            day)
                                                        .isEmpty) {
                                                      dayss.add({
                                                        "day": day,
                                                        "وقت الإغلاق": closeAt,
                                                        "وقت الإفتتاح": newValue
                                                      });
                                                    } else {
                                                      var prevDay = dayss[
                                                          dayss.indexWhere(
                                                              (element) =>
                                                                  element[
                                                                      'day'] ==
                                                                  day)];
                                                      dayss.removeWhere(
                                                          (element) =>
                                                              element['day'] ==
                                                              day);
                                                      dayss.add({
                                                        "day": day,
                                                        "وقت الإغلاق": prevDay[
                                                            "وقت الإغلاق"],
                                                        "وقت الإفتتاح": newValue
                                                      });
                                                    }
                                                    setState(() {});
                                                  },
                                                  onClose: () {
                                                    print('Picker closed');
                                                  },
                                                  buttonWidth: 80,
                                                  titleAlignment:
                                                      CrossAxisAlignment.center,
                                                  buttonSingleColor:
                                                      const Color(0xFF6db881),
                                                  displayButtonIcon: false,
                                                  buttonText:
                                                      translation(context).save,
                                                  use24hFormat: false,
                                                  minuteInterval: 15,
                                                  initialTime: Time(
                                                    minutes: 0,
                                                  ),
                                                ).show(context);
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          width: 1,
                                                          color: Colors.black),
                                                    )),
                                                child: Text(
                                                  dayss
                                                          .where((element) =>
                                                              element['day'] ==
                                                              day)
                                                          .isNotEmpty
                                                      ? dayss[dayss.indexWhere(
                                                              (element) =>
                                                                  element[
                                                                      'day'] ==
                                                                  day)]
                                                          ['وقت الإفتتاح']
                                                      : openAt,
                                                  style: const TextStyle(
                                                      fontSize: 25),
                                                ),
                                              ),
                                            )
                                          ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ]),
                  );
                }).toList(),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF6db881)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(translation(context).save),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDateDateTime,
      // Use the current value as the initial value
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            startDateDateTime), // Use the current value as the initial value
      );

      if (pickedTime != null) {
        setState(() {
          startDateDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          startDate = DateFormat('yyyy-MM-dd HH:mm').format(startDateDateTime);
        });
      }
    }
  }

  Future<void> _selectFinishDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDateDateTime,
      // Use the current value as the initial value
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            startDateDateTime), // Use the current value as the initial value
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (combinedDateTime.isBefore(startDateDateTime)) {
          // Finish date is before the start date, show an error message.
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(translation(context).wrong),
                content: Text(translation(context).endDateCon),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(translation(context).agree),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            finishDate =
                DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
          });
        }
      }
    }
  }

  bool? hasReservation;

  String priceRange = 'مرتفع';

  Set<String> serves = Set<String>();
  Set<String> atmosphere = Set<String>();
  Set<String> shopType = Set<String>();

  @override
  void dispose() {
    WebLink.dispose();
    description.dispose();
    placeName.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedFiles = [];

  List areasList = [];

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        translation(context).cancel,
        style: TextStyle(
          fontFamily: "Tajawal-m",
          fontSize: 17,
          color: Color(0xFF6db881),
        ),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
      },
    );

    // Initialize the "تأكيد" button but defer setting its onPressed callback
    Widget continueButton;

    AlertDialog alert = AlertDialog(
      content: Text(
        translation(context).sureADD,
        style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
        // textDirection: TextDirection.rtl,
      ),
      actions: [
        cancelButton,
        // Set the "تأكيد" button's onPressed callback
        continueButton = TextButton(
          onPressed: () async {
            Navigator.of(context).pop();

            final FirebaseAuth auth = FirebaseAuth.instance;
            final User? user = auth.currentUser;
            final userId = user!.uid;
            List<String> arrImage = [];
            for (int i = 0; i < selectedFiles.length; i++) {
              var imageUrl = await uploadFile(selectedFiles[i], userId);
              arrImage.add(imageUrl.toString());
            }

            var uuid = const Uuid();
            place_id = uuid.v4();
            if (type1 == 'فعاليات و ترفيه') {
              await FirebaseFirestore.instance
                  .collection('PendingPlaces')
                  .doc(place_id)
                  .set({
                'place_id': place_id,
                'User_id': userId,
                'placeName': placeName.text,
                'city': city,
                'neighbourhood': address,
                'images': arrImage,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                "WorkedDays": dayss,
                "INorOUT": INorOUT,
                "hasReservation": hasReservation,
                'isTemporary': isTemporary,
                'WebLink': WebLink.text,
                'startDate': startDate,
                'finishDate': finishDate,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
                'reservationDetails': reservationDetails,
                'typeEnt': typeEnt,
              });
              /* await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });*/
              setState(() {
                HomePageState.isDownloadedData = false;
              });
            } else if (type1 == 'مطاعم') {
              await FirebaseFirestore.instance
                  .collection('PendingPlaces')
                  .doc(place_id)
                  .set({
                'place_id': place_id,
                'User_id': userId,
                'placeName': placeName.text,
                'city': city,
                'neighbourhood': address,
                'images': arrImage,
                'WebLink': WebLink.text,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                'cuisine': cuisine,
                'priceRange': priceRange,
                'serves': serves,
                'atmosphere': atmosphere,
                "WorkedDays": dayss,
                'hasReservation': hasReservation,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
                'allowChildren': allowChildren,
                'reservationDetails': reservationDetails,
              });
              /*await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });*/
              setState(() {
                HomePageState.isDownloadedData = false;
              });
            } else if (type1 == 'مراكز تسوق') {
              await FirebaseFirestore.instance
                  .collection('PendingPlaces')
                  .doc(place_id)
                  .set({
                'place_id': place_id,
                'User_id': userId,
                'placeName': placeName.text,
                'city': city,
                'neighbourhood': address,
                'images': arrImage,
                'WebLink': WebLink.text,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                'hasCinema': hasCinema,
                'INorOUT': INorOUT,
                'hasFoodCourt': hasFoodCourt,
                'hasPlayArea': hasPlayArea,
                "WorkedDays": dayss,
                'hasSupermarket': hasSupermarket,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
                'shopType': shopType,
              });
              /*await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });*/
              setState(() {
                HomePageState.isDownloadedData = false;
              });
            } else if (type1 == null) {
              // If no category is selected, you can set a default display attribute here

              await FirebaseFirestore.instance
                  .collection('PendingPlaces')
                  .doc(place_id)
                  .set({
                'place_id': place_id,
                'User_id': userId,
                'placeName': placeName.text,
                'city': city,
                'neighbourhood': address,
                'images': arrImage,
                'WebLink': WebLink.text,
                'description': description.text,
                'category': type1,
                "WorkedDays": dayss,
                'hasValetServiced': hasValetServiced,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
              });
            }
            // Show the toast message
            Fluttertoast.showToast(
              msg: translation(context).succADD,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: const Color(0xFF6db881),
              textColor: Colors.black,
              fontSize: 25,
            );
          },
          child: Text(
            translation(context).agree,
            style: TextStyle(
              fontFamily: "Tajawal-m",
              color: Color(0xFF6db881),
            ),
          ),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var citiesList = [
      translation(context).riyadh,
      translation(context).jeddah,
      translation(context).abha,
      translation(context).east,
    ];

    List<String> cuisineOptions = [
      translation(context).saudi,
      translation(context).italian,
      translation(context).american,
      translation(context).asian,
      translation(context).indian,
      translation(context).mexican,
      translation(context).turkish,
      translation(context).seafood,
      translation(context).spanish,
      translation(context).middle_eastern,
      translation(context).greek,
      translation(context).bakery,
      translation(context).international,
      translation(context).healthy,
      translation(context).coffee_and_desserts,
    ];
    List<String> isThereInMalls = [
      translation(context).cinema,
      translation(context).play_area,
      translation(context).restaurant_area,
      translation(context).supermarket,
    ];
    List<String> typeEntOptions = [
      translation(context).sports_and_adventure,
      translation(context).arts,
      translation(context).historical_sites,
      translation(context).culture,
      translation(context).gardens_and_parks,
      translation(context).amusement_park,
      translation(context).exhibitions,
    ];
    List<String> shopOptions = [
      translation(context).clothing,
      translation(context).shoes,
      translation(context).bags,
      translation(context).furniture,
      translation(context).electronics,
      translation(context).utensils,
      translation(context).perfumes,
      translation(context).abayas,
      translation(context).jewelry,
      translation(context).children_clothing,
      translation(context).cosmetics,
      translation(context).pharmacies,
      translation(context).other,
    ];
    List<String> atmosphereOptions = [
      translation(context).music,
      translation(context).no_music,
      translation(context).by_the_sea,
      translation(context).indoor,
      translation(context).outdoor,
    ];
    List<String> servesOptions = [
      translation(context).breakfast,
      translation(context).lunch,
      translation(context).dinner,
    ];



    return  Column(
        children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            translation(context).placeDetails,
            style: TextStyle(
                fontSize: 20.0, fontFamily: "Tajawal-b", color: Colors.black),

          ),
        ),
        Expanded(

          child: Container(
            alignment: isArabic() ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,

            margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isArabic()? CrossAxisAlignment.end:CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Tajawal-b",
                        color: Colors
                            .black, // Set the color for the non-red part of the text
                      ),
                      children: [
                        TextSpan(
                          text: translation(context).placeName,
                        ),
                        TextSpan(
                          text: ' *', // Added red asterisk
                          style: TextStyle(
                            color: Colors
                                .red, // Set the color for the red asterisk
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: placeName,
                    textAlign: isArabic()? TextAlign.end: TextAlign.start,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: const Color(0xFF6db881),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.only(
                          top: 0, bottom: 0, right: 10, left: 10),
                      fillColor: Colors.white,
                      hintText: translation(context).placeName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide:
                            BorderSide(color: Color(0xFF6db881), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF6db881),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.red, // Set the color for the red border
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.red, // Set the color for the red border
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translation(context).req;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  RichText(

                    text: TextSpan(

                      style: TextStyle(

                        fontSize: 18.0,
                        fontFamily: "Tajawal-b",
                        color: Colors
                            .black, // Set the color for the non-red part of the text
                      ),
                      children: [

                        TextSpan(

                          text: translation(context).placeClass,
                        ),
                        TextSpan(
                          text: ' *', // Added red asterisk
                          style: TextStyle(
                            color: Colors
                                .red, // Set the color for the red asterisk
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    alignment: isArabic() ? Alignment.centerRight : Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: null,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        prefixIcon: isArabic()
                            ? Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        )
                            : null,
                        suffixIcon: !isArabic()
                            ? Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        )
                            : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical:15),
                      ),
                      iconSize: 0,
                      hint:
                         Text(
                          translation(context).category,
                          textAlign: isArabic() ? TextAlign.right : TextAlign.left,
                        ),

                      isExpanded: true,
                      items: [
                        DropdownMenuItem<int>(
                          value: 1,
                          child:  Text(
                              translation(context).ent,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: isArabic() ? TextAlign.end : TextAlign.start,
                            ),

                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child:  Text(
                              translation(context).rest,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: isArabic() ? TextAlign.end : TextAlign.start,
                            ),

                        ),
                        DropdownMenuItem<int>(
                          value: 3,
                          child:Text(
                              translation(context).mall,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: isArabic() ? TextAlign.end : TextAlign.start,
                            ),

                        ),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          type = value!;
                          if (type == 1)
                            type1 = 'فعاليات و ترفيه';
                          if (type == 2)
                            type1 = 'مطاعم';
                          if (type == 3)
                            type1 = 'مراكز تسوق';
                        });
                      },
                    ),
                  ),



                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Tajawal-b",
                        color: Colors
                            .black, // Set the color for the non-red part of the text
                      ),
                      children: [
                        TextSpan(
                          text: translation(context).city,
                        ),
                        TextSpan(
                          text: ' *', // Added red asterisk
                          style: TextStyle(
                            color: Colors
                                .red, // Set the color for the red asterisk
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      menuMaxHeight: 400,
                      items: citiesList.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child:  Text(value),
                        );
                      }).toList(),
                      onChanged: (_selectedValue) async {
                        var tempCity = await cities.where((element) =>
                            (element['name_ar'] == _selectedValue || element['name_en'] == _selectedValue ));
                        var tempArea = await areas.where((element) =>
                            (element['city_id'] == tempCity.first['city_id']));
                        _AddressKey.currentState?.reset();
                        areasList.clear();
                        areasList.addAll(tempArea);
                        setState(() {
                          city = tempCity.first['name_ar'];
                          print(tempCity);
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return translation(context).pleaseSelectCity;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Tajawal-m",
                        color: Color(0xFF6db881),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        prefixIcon: isArabic()
                            ? Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        )
                            : null,
                        suffixIcon: !isArabic()
                            ? Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        )
                            : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical:15),
                      ),
                      iconSize: 0,
                      hint:  Text(
                            translation(context).selectCity,
                            textAlign: isArabic() ? TextAlign.right : TextAlign.left,

                          )
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Tajawal-b",
                        color: Colors
                            .black, // Set the color for the non-red part of the text
                      ),
                      children: [
                        TextSpan(
                          text: translation(context).neighbor,
                        ),
                        TextSpan(
                          text: ' *', // Added red asterisk
                          style: TextStyle(
                            color: Colors
                                .red, // Set the color for the red asterisk
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      menuMaxHeight: 400,
                      key: _AddressKey,
                      items: areasList.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(  Localizations.localeOf(context).languageCode == 'ar'  ? value['name_ar'] : value['name_en']),
                        );
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          address = value['name_ar'];
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return translation(context).pleaseSelectNeighbor;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Tajawal-m",
                        color: Color(0xFF6db881),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        prefixIcon: isArabic()
                            ? Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        )
                            : null,
                        suffixIcon: !isArabic()
                            ? Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        )
                            : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical:15),
                      ),
                      iconSize: 0,
                      hint:  Text(
                            translation(context).selectNeighbor,
                            textAlign: isArabic() ? TextAlign.right : TextAlign.left,

                          )
                    ),
                  ),
                  // City

                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    translation(context).workingHRS,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showWorkingHoursDialog(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF6db881)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(translation(context).addWorkingHRS),
                          ),
                          Icon(Icons.access_time)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  // Display selected working hours for weekdays
                  // Text('ساعات العمل في أيام الأسبوع: $weekdaysWorkingHr'),

                  /////////////////////////////////new attr////////////////////////////////////////////////

                  if (type == 1)
                    Column(
                      mainAxisAlignment: isArabic()?MainAxisAlignment.end:MainAxisAlignment.start,
                      crossAxisAlignment: isArabic()? CrossAxisAlignment.end:CrossAxisAlignment.start,
                      children: [
                        Text(
                          textAlign: isArabic() ? TextAlign.right : TextAlign.left,
                          translation(context).entType,


                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black54,
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              prefixIcon: isArabic()
                                  ? Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6db881),
                              )
                                  : null,
                              suffixIcon: !isArabic()
                                  ? Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6db881),
                              )
                                  : null,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical:15),
                            ),
                            iconSize: 0,
                            isExpanded: true,
                            hint:  Text(
                                  translation(context).selectEntType,
                              textAlign: isArabic() ? TextAlign.right : TextAlign.left,

                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                typeEnt = newValue ?? '';
                              });
                            },
                            items: typeEntOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child:  Text(value,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Color(0xFF6db881),
                                          fontFamily: 'Tajawal-m')),

                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isArabic()?CrossAxisAlignment.end:CrossAxisAlignment.start,
                          children: [
                            Text(
                              translation(context).tempEvent,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Tajawal-b',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: isArabic()? MainAxisAlignment.end:MainAxisAlignment.start ,
                              children: [
                                CustomRadioButton(
                                    onTap: () {
                                      setState(() {
                                        isTemporary = false;
                                      });
                                    },
                                    text: translation(context).no,
                                    value: !(isTemporary ?? true)),
                                const SizedBox(
                                  width: 10,
                                ),
                                CustomRadioButton(
                                    onTap: () {
                                      setState(() {
                                        isTemporary = true;
                                      });
                                    },
                                    text: translation(context).yes,
                                    value: isTemporary ?? false),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            Visibility(
                              visible: isTemporary ?? false,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:isArabic()?
                                      MainAxisAlignment.end:  MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          _selectFinishDate(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 7),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.black54,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: Text(
                                                        translation(context)
                                                            .selectENDdate,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontFamily:
                                                                'Tajawal-m'),
                                                      ),
                                                    ),
                                                    Text(
                                                      finishDate != ''
                                                          ? finishDate
                                                          : translation(context)
                                                              .notSpENDdate,
                                                      style: TextStyle(
                                                          fontSize: 13.0,
                                                          color: finishDate !=
                                                                  ''
                                                              ? const Color(
                                                                  0xFF6db881)
                                                              : Colors.red,
                                                          fontFamily:
                                                              'Tajawal-m'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(Icons.access_time)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          _selectStartDate(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.black54,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: Text(
                                                        translation(context)
                                                            .selectSTARTdate,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontFamily:
                                                                'Tajawal-m'),
                                                      ),
                                                    ),
                                                    Text(
                                                      startDate != ''
                                                          ? startDate
                                                          : translation(context)
                                                              .notSpSTARTdate,
                                                      style: TextStyle(
                                                          fontSize: 13.0,
                                                          color: startDate != ''
                                                              ? const Color(
                                                                  0xFF6db881)
                                                              : Colors.red,
                                                          fontFamily:
                                                              'Tajawal-m'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(Icons.access_time)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              translation(context).inORout,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Tajawal-b",
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: isArabic()? MainAxisAlignment.end:MainAxisAlignment.start ,
                              children: [
                                CustomRadioButton(
                                  onTap: () {
                                    setState(() {
                                      INorOUT = 'كلاهما';
                                    });
                                  },
                                  text: translation(context).both,
                                  value: INorOUT == 'كلاهما',
                                ),
                                const SizedBox(width: 10),
                                CustomRadioButton(
                                  onTap: () {
                                    setState(() {
                                      INorOUT = 'لا';
                                    });
                                  },
                                  text: translation(context).indoor,
                                  value: INorOUT == 'لا',
                                ),
                                const SizedBox(width: 10),
                                CustomRadioButton(
                                  onTap: () {
                                    setState(() {
                                      INorOUT = 'نعم';
                                    });
                                  },
                                  text: translation(context).outdoor,
                                  value: INorOUT == 'نعم',
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).reservation,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasReservation = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(hasReservation ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasReservation = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: hasReservation ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        if (hasReservation == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextFormField(
                              textAlign: isArabic()? TextAlign.end: TextAlign.start,

                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              cursorColor: const Color(0xFF6db881),
                              onChanged: (value) {
                                // Update the reservationDetails variable when text changes
                                reservationDetails = value;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    top: 0, bottom: 0, right: 10, left: 10),
                                fillColor: Colors.white,
                                hintText: translation(context).bookINFO,
                                hintStyle: TextStyle(
                                  color: Colors.black45,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Color(0xFF6db881), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    color: Color(0xFF6db881),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                  if (type == 2) // Check if the type is for مطاعم
                    Column(
                      mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                      crossAxisAlignment: isArabic()? CrossAxisAlignment.end :CrossAxisAlignment.start,
                      children: [
                        // Add the DropdownButtonFormField for 'cuisine'
                        Text(
                          translation(context).cuisine,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black54,
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              prefixIcon: isArabic()
                                  ? Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6db881),
                              )
                                  : null,
                              suffixIcon: !isArabic()
                                  ? Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6db881),
                              )
                                  : null,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical:15),
                            ),
                            iconSize: 0,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                cuisine.add(
                                    newValue!);
                              });
                            },
                            hint: Text(
                                  translation(context).foodType,
                                textAlign: isArabic() ? TextAlign.right : TextAlign.left,

                                ),
                            items: cuisineOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                );

                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).priceRange,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black54,
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              prefixIcon: isArabic()
                                  ? Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6db881),
                              )
                                  : null,
                              suffixIcon: !isArabic()
                                  ? Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6db881),
                              )
                                  : null,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            ),
                            iconSize: 0,
                            isExpanded: true,
                            value: null,
                            onChanged: (String? newValue) {
                              setState(() {
                                priceRange = newValue!;
                                print(priceRange);
                              });
                            },
                            hint: Text(
                              translation(context).choosePriceRange,
                              textAlign: isArabic() ? TextAlign.right : TextAlign.left,
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: 'مرتفع',
                                child: Text(
                                translation(context).high,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Tajawal-m',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value:'متوسط',
                                child: Text(
                                  translation(context).medium,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Tajawal-m',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value:   'منخفض',
                                child: Text(
                                  translation(context).low,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Tajawal-m',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          translation(context).meals,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: WrapAlignment.end,
                          children: servesOptions.map((serve) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (serves.contains(serve)) {
                                      serves.remove(serve);
                                    } else {
                                      serves.add(serve);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: serves.contains(serve)
                                          ? const Color(0xFF6db881)
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(serve,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      serves.contains(serve)
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: Color(0xFF6db881),
                                            )
                                          : const SizedBox(
                                              width: 16,
                                            ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Add the CheckBoxes for 'atmosphere'
                        Text(
                          translation(context).atmosphere,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: isArabic()?WrapAlignment.end:WrapAlignment.start,
                          children: atmosphereOptions.map((atmosphereOption) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (atmosphere.contains(atmosphereOption)) {
                                      atmosphere.remove(atmosphereOption);
                                    } else {
                                      atmosphere.add(atmosphereOption);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color:
                                          atmosphere.contains(atmosphereOption)
                                              ? const Color(0xFF6db881)
                                              : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(atmosphereOption,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      atmosphere.contains(atmosphereOption)
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: Color(0xFF6db881),
                                            )
                                          : const SizedBox(
                                              width: 16,
                                            ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          translation(context).reservation,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasReservation = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(hasReservation ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasReservation = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: hasReservation ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        if (hasReservation == true)
                          if (hasReservation == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                textAlign: isArabic()? TextAlign.end: TextAlign.start,

                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                cursorColor: const Color(0xFF6db881),
                                onChanged: (value) {
                                  // Update the reservationDetails variable when text changes
                                  reservationDetails = value;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      top: 0, bottom: 0, right: 10, left: 10),
                                  fillColor: Colors.white,
                                  hintText: translation(context).bookINFO,
                                  hintStyle: TextStyle(
                                    color: Colors.black45,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF6db881), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF6db881),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                        const SizedBox(height: 20),
                        Text(
                          translation(context).allowCHILD,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    allowChildren = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(allowChildren ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    allowChildren = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: allowChildren ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                    ),

                  if (type == 3)
                    Column(
                      mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                      crossAxisAlignment: isArabic()? CrossAxisAlignment.end :CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          translation(context).inORout,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'كلاهما';
                                });
                              },
                              text: translation(context).both,
                              value: INorOUT == 'كلاهما',
                            ),
                            const SizedBox(width: 10),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'لا';
                                });
                              },
                              text: translation(context).indoor,
                              value: INorOUT == 'لا',
                            ),
                            const SizedBox(width: 10),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'نعم';
                                });
                              },
                              text: translation(context).outdoor,
                              value: INorOUT == 'نعم',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).thereCINEMA,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasCinema = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(hasCinema ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasCinema = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: hasCinema ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).therePlayArea,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasPlayArea = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(hasPlayArea ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasPlayArea = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: hasPlayArea ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).thereRes,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasFoodCourt = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(hasFoodCourt ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasFoodCourt = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: hasFoodCourt ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).thereSUPERMARKET,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: isArabic()? MainAxisAlignment.end: MainAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasSupermarket = false;
                                  });
                                },
                                text: translation(context).no,
                                value: !(hasSupermarket ?? true)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasSupermarket = true;
                                  });
                                },
                                text: translation(context).yes,
                                value: hasSupermarket ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          translation(context).storeType,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: isArabic()?WrapAlignment.end:WrapAlignment.start,
                          children: shopOptions.map((ShopType) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (shopType.contains(ShopType)) {
                                      shopType.remove(ShopType);
                                    } else {
                                      shopType.add(ShopType);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: shopType.contains(ShopType)
                                          ? const Color(0xFF6db881)
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(ShopType,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      shopType.contains(ShopType)
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: Color(0xFF6db881),
                                            )
                                          : const SizedBox(
                                              width: 16,
                                            ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),
                  Text(
                    translation(context).thereVALET,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:isArabic()? MainAxisAlignment.end :MainAxisAlignment.start,
                    children: [
                      CustomRadioButton(
                          onTap: () {
                            setState(() {
                              hasValetServiced = false;
                            });
                          },
                          text: translation(context).no,
                          value: !(hasValetServiced ?? true)),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomRadioButton(
                          onTap: () {
                            setState(() {
                              hasValetServiced = true;
                            });
                          },
                          text: translation(context).yes,
                          value: hasValetServiced ?? false),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    translation(context).webLINK,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: WebLink,
                    textAlign: isArabic()? TextAlign.end: TextAlign.start,

                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: const Color(0xFF6db881),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.only(
                          top: 0, bottom: 0, right: 10, left: 10),
                      fillColor: Colors.white,
                      hintText: translation(context).webLINK,
                      hintStyle: TextStyle(
                        color: Colors.black45,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide:
                            BorderSide(color: Color(0xFF6db881), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF6db881),
                        ),
                      ),
                    ),
                    validator: (value) {
                      // Optional field, so no validation needed
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Tajawal-b",
                        color: Colors
                            .black, // Set the color for the non-red part of the text
                      ),
                      children: [
                        TextSpan(
                          text: translation(context).description,
                        ),
                        TextSpan(
                          text: ' *', // Added red asterisk
                          style: TextStyle(
                            color: Colors
                                .red, // Set the color for the red asterisk
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: description,
                    textAlign: isArabic()? TextAlign.end: TextAlign.start,

                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: const Color(0xFF6db881),
                    maxLines: null,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.only(
                          top: 0, bottom: 0, right: 10, left: 10),
                      fillColor: Colors.white,
                      hintText: translation(context).placeDes,
                      hintStyle: TextStyle(
                        color: Colors.black45,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide:
                            BorderSide(color: Color(0xFF6db881), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF6db881),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.red, // Set the color for the red border
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.red, // Set the color for the red border
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translation(context).req;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Tajawal-b",
                        color: Colors
                            .black, // Set the color for the non-red part of the text
                      ),
                      children: [
                        TextSpan(
                          text: translation(context).location,
                        ),
                        TextSpan(
                          text: ' *', // Added red asterisk
                          style: TextStyle(
                            color: Colors
                                .red, // Set the color for the red asterisk
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _startSearchFieldController,
                    textAlign: isArabic() ? TextAlign.end : TextAlign.start,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: const Color(0xFF6db881),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                        right: 10,
                        left: 10,
                      ),
                      fillColor: Colors.white,
                      hintText: translation(context).location,
                      hintStyle: const TextStyle(
                        color: Colors.black45,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Color(0xFF6db881), width: 1),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF6db881),
                        ),
                      ),
                      prefixIcon: isArabic()
                          ? _startSearchFieldController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          setState(() {
                            predictions = [];
                            _startSearchFieldController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear_outlined),
                      )
                          : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapView()),
                          ).then((value) {
                            print(value);
                            setState(() {
                              startPosition = value;
                              _startSearchFieldController.text = value.name;
                              predictions = [];
                            });
                          });
                        },
                        child: const Icon(Icons.location_searching,
                            color: Color(0xFF6db881)),
                      )
                          : null,
                      suffixIcon: !isArabic()
                          ? _startSearchFieldController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          setState(() {
                            predictions = [];
                            _startSearchFieldController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear_outlined),
                      )
                          : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapView()),
                          ).then((value) {
                            print(value);
                            setState(() {
                              startPosition = value;
                              _startSearchFieldController.text = value.name;
                              predictions = [];
                            });
                          });
                        },
                        child: const Icon(Icons.location_searching,
                            color: Color(0xFF6db881)),
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        if (value.isNotEmpty) {
                          //places api
                          autoCompleteSearch(value);
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translation(context).req;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),
                  if (_startSearchFieldController.text != '')
                    isLoadingPlaces
                        ? Center(
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF6db881))),
                              SizedBox(
                                width: 5,
                              ),
                              Text(translation(context).searchLOC)
                            ],
                          ))
                        : Column(children: [
                            startPosition != null
                                ? SizedBox()
                                : Card(
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFF6db881),
                                        child: Icon(
                                          Icons.my_location_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        'Select with Pin Drop',
                                      ),
                                      onTap: () async {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MapView()))
                                            .then((value) => {
                                                  setState(() {
                                                    startPosition = value;
                                                    _startSearchFieldController
                                                        .text = value.name;
                                                    predictions = [];
                                                  }),
                                                  setState(() {})
                                                });
                                      },
                                    ),
                                  ),
                            predictions.length > 0
                                ? SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                        itemCount: predictions.length,
                                        itemBuilder: (context, index) {
                                          return Card(
                                            child: ListTile(
                                              leading: const CircleAvatar(
                                                backgroundColor:
                                                    Color(0xFF6db881),
                                                child: Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              title: Text(
                                                predictions[index]
                                                    .description
                                                    .toString(),
                                              ),
                                              onTap: () async {
                                                final placeId =
                                                    predictions[index].placeId!;
                                                final details =
                                                    await googlePlace.details
                                                        .get(placeId);
                                                if (details != null &&
                                                    details.result != null &&
                                                    mounted) {
                                                  setState(() {
                                                    startPosition =
                                                        details.result;
                                                    _startSearchFieldController
                                                            .text =
                                                        details.result!.name!;

                                                    predictions = [];
                                                  });
                                                }
                                              },
                                            ),
                                          );
                                        }),
                                  )
                                : startPosition != null
                                    ? const SizedBox()
                                    : Text(
                                        translation(context).notFOUNDplace,
                                        style: TextStyle(color: Colors.red),
                                        textAlign: TextAlign.right,
                                      ),
                          ]),
                  // Upload images
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.only(top: 5),
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF6db881),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: selectedFiles.isEmpty
                        ? GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    color: Color(0xFF6db881)),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  translation(context).uploadPIC,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-m",
                                    color: Color(0xFF6db881),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: selectedFiles
                                .map(
                                  (e) => Stack(
                                    alignment: AlignmentDirectional.topEnd,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          color: Colors.grey,
                                          child: Image.file(
                                            File(e.path),
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedFiles.remove(e);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(.02),
                                          child: Icon(
                                            Icons.cancel,
                                            size: 15,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (placeName.text.isEmpty ||
                              city == null ||
                              city.isEmpty ||
                              address!.isEmpty ||
                              // WebLink.text.isEmpty ||
                              description.text.isEmpty ||
                              startPosition?.geometry?.location?.lat == null ||
                              startPosition?.geometry?.location?.lng == null) {
                            showInvalidFieldsDialog(context);
                          } else {
                            double? latitude = startPosition
                                ?.geometry?.location?.lat; // Get latitude
                            double? longitude = startPosition
                                ?.geometry?.location?.lng; // Get longitude
                            String? placeNameValue =
                                placeName.text; // Get the value of placeName
                            // Check for duplicate place before adding
                            checkForDuplicatePlace(
                                latitude: latitude,
                                longitude: longitude,
                                placeName: placeNameValue);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF6db881)),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        child: Text(
                          translation(context).addPlace,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> checkForDuplicatePlace(
      {double? latitude, double? longitude, String? placeName}) async {
    final firestore = FirebaseFirestore.instance;
    final duplicatePlaceQuery = await firestore
        .collection('ApprovedPlaces')
        .where('placeName', isEqualTo: placeName)
        .where('latitude', isEqualTo: startPosition?.geometry?.location?.lat)
        .where('longitude', isEqualTo: startPosition?.geometry?.location?.lng)
        .get();

    if (duplicatePlaceQuery.docs.isEmpty) {
      showAlertDialog(context);
    } else {
      // Matching place found, show an error message
      showPlaceAlreadyExistsDialog(context);
    }
  }

  Future<void> selectImage() async {
    try {
      final List<XFile>? imgs = await _picker.pickMultiImage();
      if (imgs != null) {
        selectedFiles.addAll(imgs);
      }
    } catch (e) {
      rethrow;
    }
    setState(() {});
  }

  Future<String?> uploadFile(XFile file, String userId) async {
    try {
      final String fileName = userId + DateTime.now().toString();
      final Reference reference =
          FirebaseStorage.instance.ref().child('images').child('$fileName.jpg');

      final UploadTask uploadTask = reference.putFile(File(file.path));
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (error) {
      print(error);
      return null;
    }
  }

  void showInvalidFieldsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            translation(context).fill,
            style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
            //textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              child: Text(
                translation(context).agree,
                style: TextStyle(
                  color: Colors.green, // Set the color to green
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void showPlaceAlreadyExistsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(translation(context).existPLACE),
          actions: [
            TextButton(
              child: Text(
                translation(context).agree,
                style: TextStyle(
                  color: Colors.green, // Set the color to green
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}


