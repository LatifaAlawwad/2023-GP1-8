import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gp/Registration/logIn.dart';
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
        title: const Padding(
          padding: EdgeInsets.only(left: 150),
          child: Text(
            "إضافة مكان",
            style: TextStyle(
              fontSize: 17,
              fontFamily: "Tajawal-b",
            ),
          ),
        ),
        toolbarHeight: 60,
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
      ),
      body: FirebaseAuth.instance.currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 79),
                    child: Text(
                      "عذراً لابد من تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Tajawal-b",
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
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF6db881)),
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
                      "تسجيل الدخول",
                      style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
                    ),
                  ),
                ],
              ),
            )
          : const CustomForm(),
    );
  }
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

  //for the location
  static final TextEditingController _startSearchFieldController =
      TextEditingController();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  DetailsResult? startPosition;

  final GlobalKey<FormFieldState> _AddressKey = GlobalKey<FormFieldState>();
  bool? hasValetServiced;
  String weekdaysWorkingHr = '';
  bool? allowChildren;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyCOT8waQ9GpvCUwXotTCZD9kSPfN8JljNk');
  }
  //for rest
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

  List<String> typeEnt = [];
  List<String> typeEntOptions = [
    'رياضة و مغامرات',
    'فنون',
    'معالم تاريخية',
    'ثقافة',
    'حدائق و منتزهات',
    'مدينة  ملاهي',
  ];

  bool? isTemporary;
  String startDate = '';
  String finishDate = '';
  bool? INorOUT;
  bool? hasCinema;
  bool? hasPlayArea;
  bool? hasFoodCourt;
  bool? hasSupermarket;

  List<Map<String, String>> workingHoursList = [
    {
      'الأحد': 'مغلق',
      'الإثنين': 'مغلق',
      'الثلاثاء': 'مغلق',
      'الأربعاء': 'مغلق',
      'الخميس': 'مغلق',
      'الجمعة': 'مغلق',
      'السبت': 'مغلق',
    }
  ];

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  Future<void> _showWorkingHoursDialog(BuildContext context) async {
    List<String?> hoursOptions = [
      'مغلق',
      'مفتوح 24 ساعة',
      'من 5 صباحًا إلى 5 مساءً',
      'من 8 صباحًا إلى 6 مساءً',
      'من 10 صباحًا إلى 7 مساءً',
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: AlertDialog(
            title: Text('إضافة ساعات العمل'),
            content: Container(
              width: double.maxFinite,
              height: 400, // Adjust the height as needed
              child: ListView.builder(
                itemCount: workingHoursList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      for (var day in workingHoursList[index].keys)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day),
                            DropdownButton<String>(
                              value: workingHoursList[index][day] ??
                                  null, // Handle null with a null option
                              items: hoursOptions.map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value ??
                                      'غير محدد'), // Display "غير محدد" for null values
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  workingHoursList[index][day] = value ??
                                      'مغلق'; // Update the selected value
                                });
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('إلغاء', style: TextStyle(color: Color(0xFF6db881))),
              ),
              TextButton(
                onPressed: () {
                  // Handle the selected working hours as needed
                  Navigator.of(context).pop();
                },
                child: Text('حفظ', style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xFF6db881)),
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked.toString();
      });
  }

  Future<void> _selectFinishDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != finishDate)
      setState(() {
        finishDate = picked.toString();
      });
  }

  String priceRange = 'مرتفع';
  bool? hasReservation;
  List<String> servesOptions = ['فطور', 'غداء', 'عشاء'];
  List<String> atmosphereOptions = [
    'يوجد موسيقى',
    'بدون موسيقى',
    'على البحر',
    'داخلي',
    'خارجي'
  ];

  List<String> ShopOptions = [
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
  Set<String> ShopType = Set<String>();

  @override
  void dispose() {
    WebLink.dispose();
    description.dispose();
    placeName.dispose();
    super.dispose();
  }



  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedFiles = [];

  var citiesList = ["الرياض", "جدة", "العلا", "المنطقة الشرقية"];
  List areasList = [];

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text(
        "إلغاء",
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
      content: const Text(
        "هل أنت متأكد من أنك تريد إضافة هذا المكان؟",
        style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
        textDirection: TextDirection.rtl,
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
            _formKey.currentState!.save();
            var uuid = Uuid();
            place_id = uuid.v4();
            if (type1 == 'فعاليات وترفيه') {
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
                'Location': WebLink.text,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                //'WeekdaysWorkingHr': weekdaysWorkingHr,
                //  'WeekendsWorkingHr': weekendsWorkingHr,
                //'longitude': longitude,
                // 'latitude': latitude,
                'isTemporary':
                    isTemporary, // Add attributes specific to Entertainment
                'startDate': startDate,
                'finishDate': finishDate,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
              });
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });
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
                'Location': WebLink.text,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                //  'WeekdaysWorkingHr': weekdaysWorkingHr,
                //  'WeekendsWorkingHr': weekendsWorkingHr,

                'cuisine': cuisine, // Add attributes specific to restaurants
                'priceRange': priceRange,
                'serves': serves,
                'atmosphere': atmosphere,
                'hasReservation': hasReservation,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
                'allowChildren': allowChildren,
              });
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });
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
                'Location': WebLink.text,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                // 'WeekdaysWorkingHr': weekdaysWorkingHr,
                //'WeekendsWorkingHr': weekendsWorkingHr,

                'hasCinema': hasCinema,
                'INorOUT': INorOUT,
                'hasFoodCourt': hasFoodCourt,
                'hasPlayArea': hasPlayArea,
                'hasSupermarket': hasSupermarket,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
              });
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });
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
                'Location': WebLink.text,
                'description': description.text,
                'category': type1,
                'hasValetServiced': hasValetServiced,
                'latitude': startPosition?.geometry?.location?.lat,
                'longitude': startPosition?.geometry?.location?.lng,
              });
            }
            // Show the toast message
            Fluttertoast.showToast(
              msg: "تم إرسال طلب الإضافة بنجاح",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: const Color(0xFF6db881),
              textColor: Colors.black,
              fontSize: 25,
            );
          },
          child: const Text(
            "موافق",
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
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: SizedBox(width: double.infinity),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(margin: const EdgeInsets.all(6)),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '  تفاصيل المكان : ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
              ),

              // Type selection section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 83, right: 25),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: placeName,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء عدم ترك الخانة فارغة!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Text(
                          ':اسم المكان ',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",

                          ),
                        ),
                        Text(
                           '*',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )


                ],
              ),
              SizedBox(
                height: 15,
              ),
              // Add more widgets here
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    // Adjust top and left values
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    height: 50,
                    width: 150,
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 8),
                        hintText: 'اختر التصنيف',
                      ),
                      items: const [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text(
                            "فعاليات و ترفيه",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Text(
                            "مطاعم",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 3,
                          child: Text(
                            "مراكز تسوق",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Text(
                          ':تصنيف المكان ',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",

                          ),
                        ),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )


                ],
              ),
              SizedBox(
                height: 10,
              ),

              // City
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        height: 50,
                        width: 155,
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          menuMaxHeight: 400,
                          items: citiesList.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (_selectedValue) async {
                            var tempCity = await cities.where((element) =>
                                (element['name_ar'] == _selectedValue));
                            var tempArea = await areas.where((element) =>
                                (element['city_id'] ==
                                    tempCity.first['city_id']));
                            _AddressKey.currentState?.reset();
                            areasList.clear();
                            areasList.addAll(tempArea);
                            setState(() {
                              city = _selectedValue.toString();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'الرجاء اختيار المدينة';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Tajawal-m",
                            color: Color(0xFF6db881),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(right: 7),
                            hintText: 'اختر المدينة',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 7),
                      ),
                      const Padding(
                          padding: EdgeInsets.only(left: 80, right: 50)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            Text(
                              ':المدينة ',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "Tajawal-b",

                              ),
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 8, left: 8),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    height: 50,
                    width: 155,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      key: _AddressKey,
                      items: areasList.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value['name_ar']),
                        );
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          address = value['name_ar'];
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء اختيار الحي';
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Tajawal-m",
                        color: Color(0xFF6db881),
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(7),
                        hintText: 'اختر الحي ',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(21),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 75, right: 50)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Text(
                          ':الحي ',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",

                          ),
                        ),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),


              SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 8, left: 8),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    width: 150, // Set the width as needed
                    height: 50,
                   // Set the height as needed
                    child: ElevatedButton(
                      onPressed: () {
                        _showWorkingHoursDialog(context);
                      },
                      child: Text('أضف ساعات العمل'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF6db881)),
                      ),
                    ),
                  ),
                  SizedBox(width: 85),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Text(
                          ': ساعات العمل ',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ), SizedBox(
          height: 15,
        ),




              // Display selected working hours for weekdays
                  // Text('ساعات العمل في أيام الأسبوع: $weekdaysWorkingHr'),


              /////////////////////////////////new attr////////////////////////////////////////////////


              if (type == 1)
                Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          height: 50,
                          width: 154,
                          child: DropdownButtonFormField<String>(
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8),
                              hintText: 'اختر نوع الفعالية',
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                typeEnt.add(newValue!);
                              });
                            },
                            items: typeEntOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(value,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                Text(
                                  ':نوع الفعالية ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),

                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'هل الفعالية مؤقتة؟',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: 'Tajawal-b',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'نعم',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: 'Tajawal-m',
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          child: Radio<bool>(
                                            value: true,
                                            groupValue: isTemporary,
                                            onChanged: (value) {
                                              setState(() {
                                                isTemporary = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: isTemporary == true,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        // Align buttons horizontally
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                finishDate ??
                                                    'تاريخ النهاية غير محدد',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Tajawal-m'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFF6db881)),
                                                onPressed: () =>
                                                    _selectFinishDate(context),
                                                child:
                                                    Text('اختر تاريخ النهاية'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            children: [
                                              Text(
                                                startDate ??
                                                    'تاريخ البداية غير محدد',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Tajawal-m'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFF6db881)),
                                                onPressed: () =>
                                                    _selectStartDate(context),
                                                child:
                                                    Text('اختر تاريخ البداية'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'لا',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: 'Tajawal-m',
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          child: Radio<bool>(
                                            value: false,
                                            groupValue: isTemporary,
                                            onChanged: (value) {
                                              setState(() {
                                                isTemporary = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: ' هل هو مكان خارجي ؟',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: "Tajawal-b",
                                        color: Colors.black, // Set the text color to black
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),


                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('نعم',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Tajawal-m')),
                                Radio(
                                  value: true,
                                  groupValue: INorOUT,
                                  onChanged: (value) {
                                    setState(() {
                                      hasValetServiced = INorOUT!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('لا',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Tajawal-m')),
                                Radio(
                                  value: false,
                                  groupValue: INorOUT,
                                  onChanged: (value) {
                                    setState(() {
                                      INorOUT = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'هل يتطلب حجز ؟ ',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: "Tajawal-b",
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' * ',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('نعم',
                                    style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                                Radio(
                                  value: true,
                                  groupValue: hasReservation,
                                  onChanged: (value) {
                                    setState(() {
                                      hasReservation = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            // Conditionally show the square-shaped TextField if 'نعم' is selected
                            if (hasReservation == true)
                              Container(
                                width: 500,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 94, right: 10),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: ' تفاصيل طريقة الحجز و رقم للتواصل إن وجد',
                                      border: OutlineInputBorder( // Set border to make it square-shaped
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('لا',
                                    style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                                Radio(
                                  value: false,
                                  groupValue: hasReservation,
                                  onChanged: (value) {
                                    setState(() {
                                      hasReservation = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),


                      ],
                    ),
                  ],
                ),
              if (type == 2) // Check if the type is for مطاعم
                Column(
                  children: [
                    // Add the DropdownButtonFormField for 'cuisine'
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          height: 50,
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8),
                              hintText: 'اختر نوع الطعام',
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                cuisine.add(
                                    newValue!); // Add the selected cuisine to the list
                              });
                            },
                            items: cuisineOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(value,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              Text(
                                ':نوع الطعام ',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: "Tajawal-b",
                                ),
                              ),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),

                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          height: 50,
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8),
                              hintText: 'اختر نطاق الأسعار',
                            ),
                            value: priceRange,
                            onChanged: (String? newValue) {
                              setState(() {
                                priceRange = newValue!;
                              });
                            },
                            items:
                                ['مرتفع', 'متوسط', 'منخفض'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(value,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              Text(
                                ':نطاق الأسعار ',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: "Tajawal-b",
                                ),
                              ),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),

                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: ':الوجبات المقدمة ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                    color: Colors.black, // Set the text color to black
                                  ),
                                ),
                                TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: servesOptions.map((serve) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 1.0),
                                  // Adjust the right padding as desired
                                  child: Text(serve,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Tajawal-m')),
                                ),
                                Checkbox(
                                  value: serves.contains(serve),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value != null && value) {
                                        serves.add(serve);
                                      } else {
                                        serves.remove(serve);
                                      }
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

// Add the CheckBoxes for 'atmosphere'
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: ':الجو العام ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                    color: Colors.black, // Set the text color to black
                                  ),
                                ),
                                TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: atmosphereOptions.map((atmosphereOption) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(atmosphereOption,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Tajawal-m')),
                                Checkbox(
                                  value: atmosphere.contains(atmosphereOption),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        atmosphere.add(atmosphereOption);
                                      } else {
                                        atmosphere.remove(atmosphereOption);
                                      }
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'هل يتطلب حجز ؟ ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('نعم',
                                style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: hasReservation,
                              onChanged: (value) {
                                setState(() {
                                  hasReservation = value;
                                });
                              },
                            ),
                          ],
                        ),
                        // Conditionally show the square-shaped TextField if 'نعم' is selected
                        if (hasReservation == true)
                          Container(
                            width: 500, // Adjust the width as needed
                            height: 50, // Adjust the height as needed
                            child: Padding(
                              padding: const EdgeInsets.only(left: 94, right: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: ' تفاصيل طريقة الحجز و رقم للتواصل إن وجد',
                                  border: OutlineInputBorder( // Set border to make it square-shaped
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('لا',
                                style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: hasReservation,
                              onChanged: (value) {
                                setState(() {
                                  hasReservation = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'هل يسمح بدخول الأطفال ؟',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Tajawal-b",
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('نعم',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: allowChildren,
                              onChanged: (value) {
                                setState(() {
                                  allowChildren = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('لا',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: allowChildren,
                              onChanged: (value) {
                                setState(() {
                                  allowChildren = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),

              if (type == 3)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: ':هل المركز داخلي أم خارجي ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                    color: Colors.black, // Set the text color to black
                                  ),
                                ),
                                TextSpan(
                                  text: '* ',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('داخلي',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: INorOUT,
                              onChanged: (value) {
                                setState(() {
                                  INorOUT = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('خارجي',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: INorOUT,
                              onChanged: (value) {
                                setState(() {
                                  INorOUT = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'هل يوجد سينما؟',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Tajawal-b",
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('نعم',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: hasCinema,
                              onChanged: (value) {
                                setState(() {
                                  hasCinema = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('لا',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: hasCinema,
                              onChanged: (value) {
                                setState(() {
                                  hasCinema = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'هل توجد منطقة ألعاب؟',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Tajawal-b",
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('نعم',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: hasPlayArea,
                              onChanged: (value) {
                                setState(() {
                                  hasPlayArea = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('لا',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: hasPlayArea,
                              onChanged: (value) {
                                setState(() {
                                  hasPlayArea = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'هل يوجد منطقة مطاعم؟',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Tajawal-b",
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('نعم',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: hasFoodCourt,
                              onChanged: (value) {
                                setState(() {
                                  hasFoodCourt = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('لا',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: hasFoodCourt,
                              onChanged: (value) {
                                setState(() {
                                  hasFoodCourt = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'هل يوجد سوبرماركت؟',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Tajawal-b",
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('نعم',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: true,
                              groupValue: hasSupermarket,
                              onChanged: (value) {
                                setState(() {
                                  hasSupermarket = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('لا',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Tajawal-m')),
                            Radio(
                              value: false,
                              groupValue: hasSupermarket,
                              onChanged: (value) {
                                setState(() {
                                  hasSupermarket = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            ': أنواع المحلات',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Tajawal-b",
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: ShopOptions.map((ShopOptions) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(ShopOptions,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Tajawal-m')),
                                Checkbox(
                                  value: ShopType.contains(ShopOptions),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        ShopType.add(ShopOptions);
                                      } else {
                                        ShopType.remove(ShopOptions);
                                      }
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'هل توجد خدمة ركن السيارات؟',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Tajawal-b",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('نعم',
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: 'Tajawal-m')),
                      Radio(
                        value: true,
                        groupValue: hasValetServiced,
                        onChanged: (value) {
                          setState(() {
                            hasValetServiced = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('لا',
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: 'Tajawal-m')),
                      Radio(
                        value: false,
                        groupValue: hasValetServiced,
                        onChanged: (value) {
                          setState(() {
                            hasValetServiced = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 83, right: 25),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: WebLink,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء عدم ترك الخانة فارغة!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ' :رابط الموقع الالكتروني  ',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontFamily: "Tajawal-b",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 94, right: 10),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start, // Adjusted to MainAxisAlignment.start
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start, // Adjusted to MainAxisAlignment.end
                              children: [
                                Text(
                                  ' وصف المكان : ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Tajawal-b",
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextFormField(
                                  controller: description,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  maxLines: null,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء عدم ترك الخانة فارغة!';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 25,
              ),
              TextFormField(
                  controller: _startSearchFieldController,
                  decoration: InputDecoration(

                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 202, 198, 198)),
                      label: RichText(
                        text: TextSpan(
                            text: 'الموقع',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87),
                            children: [
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ))
                            ]),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black87, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6db881),
                          width: 2.0,
                        ),
                      ),
                      suffixIcon: _startSearchFieldController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  predictions = [];
                                  _startSearchFieldController.clear();
                                });
                              },
                              icon: Icon(Icons.clear_outlined),
                            )
                          : Icon(Icons.location_searching,
                              color: Color(0xFF6db881))),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (value.isNotEmpty) {
                        //places api
                        autoCompleteSearch(value);
                      } else {
                        //clear out the results
                        setState(() {
                          predictions = [];
                          startPosition = null;
                        });
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'required';
                    }
                  }),
              Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF6db881),
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          predictions[index].description.toString(),
                        ),
                        onTap: () async {
                          final placeId = predictions[index].placeId!;
                          final details =
                          await googlePlace.details.get(placeId);
                          if (details != null &&
                              details.result != null &&
                              mounted) {
                            setState(() {
                              startPosition = details.result;
                              _startSearchFieldController.text =
                              details.result!.name!;

                              predictions = [];
                            });
                          }
                        },
                      );
                    }),
              ),


              // Upload images
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  // Adjust the top padding as needed
                  child: Container(
                    height: 100,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFF6db881),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: SizedBox(
                      height: 95,
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          selectedFiles.isEmpty
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  child: TextButton(
                                    child: const Text(
                                      '+إرفق صور للمكان',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: "Tajawal-m",
                                        color: Color(0xFF6db881),
                                      ),
                                    ),
                                    onPressed: () {
                                      selectImage();
                                    },
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        100,
                                    right: MediaQuery.of(context).size.height /
                                        100,
                                    bottom: MediaQuery.of(context).size.height /
                                        100,
                                  ),
                                  height: 100,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    children: selectedFiles
                                        .map(
                                          (e) => Stack(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
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
                        ],
                      ),
                    ),
                  )),

              Container(
                margin: const EdgeInsets.all(20),
              ),
              Container(
                margin: const EdgeInsets.all(3),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ElevatedButton(
                  onPressed: () async {
                    if (placeName.text.isEmpty ||
                        city == null ||
                        city.isEmpty ||
                        address!.isEmpty ||
                        WebLink.text.isEmpty ||
                        description.text.isEmpty) {
                      showInvalidFieldsDialog(context);
                    } else {
                      // Check for duplicate place before adding
                      await checkForDuplicatePlace();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF6db881)),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                  ),
                  child: const Text(
                    'إضافة المكان',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Tajawal-m",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkForDuplicatePlace() async {
    final firestore = FirebaseFirestore.instance;
    final duplicatePlaceQuery = await firestore
        .collection('ApprovedPlaces')
        .where('placeName', isEqualTo: placeName.text)
        .where('city', isEqualTo: city)
        // .where('location', isEqualTo: location.text)
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
          content: const Text(
            "الرجاء ملء جميع التفاصيل!",
            style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              child: Text("موافق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
          content: Text("المكان موجود مسبقا"),
          actions: <Widget>[
            TextButton(
              child: Text("موافق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
