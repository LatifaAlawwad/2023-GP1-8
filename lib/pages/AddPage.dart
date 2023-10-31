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
import 'HomePage.dart';

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
  int type = 1;
  String type1 = 'أماكن سياحية';

  String place_id = '';
  String city = "الرياض";
  String? address;
  final location = TextEditingController();
  final description = TextEditingController();
  final placeName = TextEditingController();
  final GlobalKey<FormFieldState> _AddressKey = GlobalKey<FormFieldState>();
  bool hasValet = false;
  String weekdaysWorkingHr = '';
  String weekendsWorkingHr = '';
  String longitude = '';
  String latitude = '';


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


  String priceRange = "غالي";
  bool? hasReservation;
  List<String> servesOptions = ['فطور', 'غداء', 'عشاء'];
  List<String> atmosphereOptions = [
    'يوجد موسيقى',
    'بدون موسيقى',
    'على البحر',
    'داخلي',
    'خارجي'
  ];
  Set<String> serves = Set<String>();
  Set<String> atmosphere = Set<String>();

  @override
  void dispose() {
    location.dispose();
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
              await FirebaseFirestore.instance.collection('PendingPlaces')
                  .doc(
                  place_id)
                  .set({
              'place_id': place_id,
              'User_id': userId,
              'placeName': placeName.text,
              'city': city,
              'neighbourhood': address,
              'images': arrImage,
              'Location': location.text,
              'description': description.text,
              'category': type1,
              'hasValet': hasValet,
              'WeekdaysWorkingHr': weekdaysWorkingHr,
              'WeekendsWorkingHr': weekendsWorkingHr,
              'longitude': longitude,
              'latitude': latitude,
              'isTemporary': isTemporary, // Add attributes specific to Entertainment
              'startDate': startDate,
              'finishDate': finishDate,


              });
              await FirebaseFirestore.instance.collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });
            }
            if (type1 == 'مطاعم') {
              await FirebaseFirestore.instance.collection('PendingPlaces')
                  .doc(
                  place_id)
                  .set({
                'place_id': place_id,
                'User_id': userId,
                'placeName': placeName.text,
                'city': city,
                'neighbourhood': address,
                'images': arrImage,
                'Location': location.text,
                'description': description.text,
                'category': type1,
                'hasValet': hasValet,
                'WeekdaysWorkingHr': weekdaysWorkingHr,
                'WeekendsWorkingHr': weekendsWorkingHr,
                'longitude': longitude,
                'latitude': latitude,
                'cuisine': cuisine, // Add attributes specific to restaurants
                'priceRange': priceRange,
                'serves': serves,
                'atmosphere': atmosphere,
                'hasReservation': hasReservation,


              });
              await FirebaseFirestore.instance.collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
              });
            }
            if (type1 == 'مراكز تسوق') {
              await FirebaseFirestore.instance.collection('PendingPlaces')
                  .doc(
                  place_id)
                  .set({
                'place_id': place_id,
                'User_id': userId,
                'placeName': placeName.text,
                'city': city,
                'neighbourhood': address,
                'images': arrImage,
                'Location': location.text,
                'description': description.text,
                'category': type1,
                'hasValet': hasValet,
              'WeekdaysWorkingHr': weekdaysWorkingHr,
              'WeekendsWorkingHr': weekendsWorkingHr,
              'longitude': longitude,
              'latitude': latitude,
              'hasCinema': hasCinema,
              'INorOUT': INorOUT,
              'hasFoodCourt': hasFoodCourt,
                'hasPlayArea': hasPlayArea,
                'hasSupermarket': hasSupermarket,


              });
              await FirebaseFirestore.instance.collection('users')
                  .doc(userId)
                  .update({
                "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
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
                          autovalidateMode: AutovalidateMode
                              .onUserInteraction,
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
                      ':اسم المكان ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Tajawal-b",
                      ),
                    ),
                  ),
                ],
              ),

              // Add more widgets here
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    // Adjust top and left values
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)),
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
                  const Text(
                    'تصنيف المكان: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Tajawal-b",
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
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
                          autovalidateMode: AutovalidateMode
                              .onUserInteraction,
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
                          padding: EdgeInsets.only(left: 100, right: 50)),
                      const Text(
                        'المدينة : ',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: "Tajawal-b",
                        ),
                        textDirection: TextDirection.rtl,
                      ),
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
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.grey.shade300, width: 1),
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
                  const Padding(
                      padding: EdgeInsets.only(left: 100, right: 50)),
                  const Text(
                    ': الحي ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 83, right: 25),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          // Add top margin to move the field down
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: TextFormField(
                              controller: description,
                              autovalidateMode: AutovalidateMode
                                  .onUserInteraction,
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
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ': وصف المكان',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Tajawal-b",
                      ),
                    ),
                  ),
                ],
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
                          controller: location,
                          autovalidateMode: AutovalidateMode
                              .onUserInteraction,
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
                      ': رابط الموقع ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Tajawal-b",
                      ),
                    ),
                  ),
                ],
              ),
              //////////////////////////////////////////////////////rest/////////////////////////////////
              if (type == 1)
      Column(
      children: [
      const SizedBox(height: 20),
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      Container(
      margin: const EdgeInsets.only(top: 10, left: 10),
      decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: Colors.white,
      border: Border.all(
      color: Colors.grey.shade300,
      width: 2,
      ),
      ),
      height: 50,
      width: 180,
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
      child: Text(value, style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
      ),
      );
      }).toList(),
      ),
      ),
      const Align(
      alignment: Alignment.centerRight,
      child: Text(
      ':نوع الفعالية',
      style: TextStyle(
      fontSize: 20.0,
      fontFamily: "Tajawal-b",
      ),
      ),
      ),
      ],
      ),
      SizedBox(height: 20),
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      const Align(
      alignment: Alignment.centerRight,
      child: Text(
      'هل الفعالية مؤقتة؟',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text(
                      'نعم',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Tajawal-m',
                      ),
                    ),
                    Container( // Add a container for the radio button with margin
                      margin: const EdgeInsets.only(left: 10),
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
                Row(
                  children: [
                    const Text(
                      'لا',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Tajawal-m',
                      ),
                    ),
                    Container( // Add a container for the radio button with margin
                      margin: const EdgeInsets.only(left: 10),
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

            Visibility(
              visible: isTemporary == true,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            startDate ?? 'اختر تاريخ البداية',
                            style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m'),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectStartDate(context),
                            child: Text('اختر تاريخ البداية'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            finishDate ?? 'اختر تاريخ النهاية',
                            style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m'),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectFinishDate(context),
                            child: Text('اختر تاريخ النهاية'),
                          ),
                        ],
                      ),
                    ],
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
                Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                Radio(
                  value: true,
                  groupValue: hasValet,
                  onChanged: (value) {
                    setState(() {
                      hasValet = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                Radio(
                  value: false,
                  groupValue: hasValet,
                  onChanged: (value) {
                    setState(() {
                      hasValet = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        )


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
    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
    cuisine.add(newValue!); // Add the selected cuisine to the list
    });
    },
    items: cuisineOptions.map((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Align(
    alignment: Alignment.centerRight,
    child: Text(value, style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
    ),
    );
    }).toList(),
    ),
    ),
    Align(
    alignment: Alignment.centerRight,
    child: Text(
    ':نوع الطعام',
    style: TextStyle(
    fontSize: 20.0,
    fontFamily: "Tajawal-b",
    ),
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
    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
    items: ['غالي', 'متوسط', 'منخفض'].map((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Align(
    alignment: Alignment.centerRight,
    child: Text(value, style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
    ),
    );
    }).toList(),
    ),
    ),
    Align(
    alignment: Alignment.centerRight,
    child: Text(
    ':نطاق الأسعار',
    style: TextStyle(
    fontSize: 20.0,
    fontFamily: "Tajawal-b",
    ),
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
    child: Text(
    ':الوجبات المقدمة',
    style: TextStyle(
    fontSize: 20.0,
    fontFamily: "Tajawal-b",
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
    padding: const EdgeInsets.only(right: 1.0), // Adjust the right padding as desired
    child: Text(serve, style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
    child: Text(
    ':الجو العام',
    style: TextStyle(
    fontSize: 20.0,
    fontFamily: "Tajawal-b",
    ),
    ),
    ),
    SizedBox(height: 10),
    Column(
    children: atmosphereOptions.map((atmosphereOption) {
    return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
    Text(atmosphereOption, style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
// Add Switch for 'hasReservation'
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Align(
    alignment: Alignment.centerRight,
    child: Text(
    'هل يتطلب حجز؟',
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
    Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
    Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
    Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                        child: Text(
                          'هل المركز داخلي أم خارجي؟',
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
                          Text('داخلي', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('خارجي', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
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
                          Text('نعم', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                          Radio(
                            value: true,
                            groupValue: hasValet,
                            onChanged: (value) {
                              setState(() {
                                hasValet = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('لا', style: TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m')),
                          Radio(
                            value: false,
                            groupValue: hasValet,
                            onChanged: (value) {
                              setState(() {
                                hasValet = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
],
    ),

                  // Upload images
    Padding(
    padding: const EdgeInsets.only(top: 50.0 ), // Adjust the top padding as needed
    child:Container(
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
    width: MediaQuery.of(context).size.width / 1.1,
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
    top: MediaQuery.of(context).size.height / 100,
    right: MediaQuery.of(context).size.height / 100,
    bottom: MediaQuery.of(context).size.height / 100,
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
    onPressed: () {
    if (placeName.text.isEmpty ||
    city == null || city.isEmpty ||
    address!.isEmpty ||
    location.text.isEmpty ||
    description.text.isEmpty) {
    showInvalidFieldsDialog(context);
    } else {
    showAlertDialog(context);
    }
    },
    style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(const Color(0xFF6db881)),

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


  Future<String?> uploadFile(XFile file, String userId) async {
    try {
      final String fileName = userId + DateTime.now().toString();
      final Reference reference = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('$fileName.jpg');

      final UploadTask uploadTask = reference.putFile(File(file.path));
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
