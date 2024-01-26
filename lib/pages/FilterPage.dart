import 'dart:async';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gp/Registration/logIn.dart';
import 'package:gp/helper/CustomRadioButton.dart';
import 'package:gp/helper/MapViewDrop.dart';
import 'package:gp/pages/MapView.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'neighbourhood.dart';
import 'cities.dart';
import 'MyPlacesPage.dart';
import 'HomePage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

  static const appTitle = 'تصفية';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: const Color.fromARGB(255, 109, 184, 129),
        elevation: 0.0, // Set the elevation to 0.0 to remove the shadow
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 150),
          child: Text(
            "تصفية",
            style: TextStyle(
              fontSize: 22,
              fontFamily: "Tajawal-b",
            ),
          ),
        ),
        toolbarHeight: 60,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.close_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [



          /*Column(
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
          ),*/
          Column(
            children: [
              Expanded(
                child:

                  Container(
                    color: const Color(0xff6db881),
                  ),

              ),

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
  bool? isOutdoor;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyCOT8waQ9GpvCUwXotTCZD9kSPfN8JljNk');
  }

  //for rest
  List<String> userChecked = [];
  List<String> cuisine = [];
  List<String> cuisineOptions = [
    'سعودي',
    'إيطالي',
    'أمريكي',
    'آسيوي',
    'هندي',
    'مكسيكي',
    'تركي',
    ' بحري',
    'إسباني',
    'شرقي',
    'يوناني',
    'مخبوزات',
    'عالمي',
    'صحي',
  ];

  List<bool> checkedOptions = [false, false, false,false,false,false,false];
  List<String> isThereInMalls=['سينما','منطقة ألعاب','منطقة مطاعم','سوبرماركت']  ;
  List<String> typeEntOptions = [
    'رياضة و مغامرات',
    'فنون',
    'معالم تاريخية',
    'ثقافة',
    'حدائق و منتزهات',
    'مدينة  ملاهي',
    'معارض',
  ];

  bool? isTemporary;
  String startDate = '';
  String finishDate = '';
  bool? INorOUT;
  bool? hasCinema;
  bool? hasPlayArea;
  bool? hasFoodCourt;
  bool? hasSupermarket;
  String reservationDetails='';
  String typeEnt='';




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












  bool? hasReservation;
  List<String> servesOptions = ['فطور', 'غداء', 'عشاء'];
  String priceRange = 'مرتفع';
  List<String> atmosphereOptions = [
    'يوجد موسيقى',
    'بدون موسيقى',
    'على البحر',
    'داخلي',
    'خارجي'
  ];
  List<String> shopOptions = [
    'ملابس',
    'أحذية',
    'حقائب',
    'أثاث',
    'الكترونيات',
    'أواني',
    'عطور',
    'عبايات',
    'مجوهرات',
    'ملابس أطفال',
    'مستحضرات تجميل',
    'صيدليات',
    'أخرى'
  ];
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


  List areasList = [];



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Expanded(
          child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [



                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    ':تصنيف المكان ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    // Adjust top and left values
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: null, // Set initial value to null
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.arrow_drop_down, // Set your desired icon
                          color: Color(0xFF6db881),
                        ),
                        contentPadding: EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
                      ),
                      iconSize: 0,
                      hint: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اختر تصنيف المكان',
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "فعاليات و ترفيه",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "مطاعم",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "مراكز تسوق",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          type = value!;
                          if (type == 1) type1 = 'فعاليات و ترفيه';
                          if (type == 2) type1 = 'مطاعم';
                          if (type == 3) type1 = 'مراكز تسوق';
                        });
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),




                  /////////////////////////////////new attr////////////////////////////////////////////////

                  if (type == 1)
                  Column(



                    mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        const SizedBox(height: 10),
                        const Text(
                          'نوع الفعالية',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: typeEntOptions.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    typeEntOptions[index],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Tajawal-m",
                                      color: Color(0xFF6db881),
                                    ),
                                  ),
                                ),
                                activeColor: const Color.fromARGB(
                                    255, 70, 147, 90), // Set the check color to green
                                controlAffinity: ListTileControlAffinity.trailing,
                                value: checkedOptions[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedOptions[index] = value ?? false;
                                    if (value ?? false) {
                                      typeEnt = typeEntOptions[index];
                                    } else {
                                      typeEnt = ''; // Reset if unchecked
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),


                        Divider(height:50, color: Colors.grey),

                        const Text(
                          'طبيعة الفعالية',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (INorOUT == false) {
                                    INorOUT = null;
                                  } else {
                                    INorOUT = false;
                                  }
                                });
                              },
                              text: 'خارجي',
                              value: INorOUT == false,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (INorOUT == true) {
                                    INorOUT = null;
                                  } else {
                                    INorOUT = true;
                                  }
                                });
                              },
                              text: 'داخلي',
                              value: INorOUT == true,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),


                        Divider(height:50, color: Colors.grey),

                        const Text(
                          'الحجز',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (hasReservation == false) {
                                    hasReservation = null;
                                  } else {
                                    hasReservation = false;
                                  }
                                });
                              },
                              text: 'يتطلب حجز',
                              value: hasReservation == false,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (hasReservation == true) {
                                    hasReservation = null;
                                  } else {
                                    hasReservation = true;
                                  }
                                });
                              },
                              text: 'لا يتطلب حجز',
                              value: hasReservation == true,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),




                      ],
                    ),

                  if (type == 2) // Check if the type is for مطاعم
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Add the DropdownButtonFormField for 'cuisine'
                        const Text(
                          'نوع الطعام ',
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
                              width: 2,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.arrow_drop_down, // Set your desired icon
                                color: Color(0xFF6db881),
                              ),
                              contentPadding: EdgeInsets.only(
                                  top: 15, bottom: 15, right: 10, left: 10),
                            ),
                            iconSize: 0,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                cuisine.add(
                                    newValue!); // Add the selected cuisine to the list
                              });
                            },
                            hint: const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'اختر نوع الطعام',
                                )),
                            items: cuisineOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(value,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'نطاق الأسعار ',
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
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.arrow_drop_down, // Set your desired icon
                                color: Color(0xFF6db881),
                              ),
                              contentPadding: EdgeInsets.only(
                                  top: 15, bottom: 15, right: 10, left: 10),
                            ),
                            iconSize: 0,
                            isExpanded: true,
                            value: priceRange,
                            onChanged: (String? newValue) {
                              setState(() {
                                priceRange = newValue!;
                              });
                            },
                            hint: const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'اختر نطاق الأسعار',
                                )),
                            items:
                            ['مرتفع', 'متوسط', 'منخفض'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(value,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'الوجبات المقدمة ',
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
                        const Text(
                          'الجو العام ',
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
                        const Text(
                          'هل يتطلب حجز ؟ ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                                onTap: () {
                                  setState(() {
                                    hasReservation = false;
                                  });
                                },
                                text: 'لا',
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
                                text: 'نعم',
                                value: hasReservation ?? false),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),





                      ],
                    ),

                  if (type == 3)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        const SizedBox(height: 10),


                        const Text(
                          'طبيعة الفعالية',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (INorOUT == false) {
                                    INorOUT = null;
                                  } else {
                                    INorOUT = false;
                                  }
                                });
                              },
                              text: 'خارجي',
                              value: INorOUT == false,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (INorOUT == true) {
                                    INorOUT = null;
                                  } else {
                                    INorOUT = true;
                                  }
                                });
                              },
                              text: 'داخلي',
                              value: INorOUT == true,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),

                        Divider(height:50, color: Colors.grey),

                        const Text(
                         'يوجد في مراكز التسوق',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: isThereInMalls.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    isThereInMalls[index],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Tajawal-m",
                                      color: Color(0xFF6db881),
                                    ),
                                  ),
                                ),
                                activeColor: const Color.fromARGB(
                                    255, 70, 147, 90), // Set the check color to green
                                controlAffinity: ListTileControlAffinity.trailing,
                                value: checkedOptions[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedOptions[index] = value ?? false;
                                    if (value ?? false) {
                                      typeEnt = isThereInMalls[index];
                                    } else {
                                      typeEnt = ''; // Reset if unchecked
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),






                        Divider(height:50, color: Colors.grey),

                        const Text(
                          'أنواع المحلات',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: WrapAlignment.end,
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
                      ],),

































                  const SizedBox(
                    width: 10,
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Button press logic
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(const Color(0xFF6db881)),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const Text(
                              'مسح الكل',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Tajawal-m",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // Adjust the spacing between buttons
                          ElevatedButton(
                            onPressed: () async {
                              // Second button press logic
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(const Color(0xFF6db881)),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const Text(
                              'عرض النتائج',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Tajawal-m",
                              ),
                            ),
                          ),
                        ],
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







}
