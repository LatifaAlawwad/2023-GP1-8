// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, curly_braces_in_flow_control_structures
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Registration/logIn.dart';
import 'AddPage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'neighbourhood.dart';
import 'cities.dart';
import 'homepage.dart';






class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

    const appTitle = 'إضافة مكان';
    return Scaffold(
      appBar: AppBar(
        // bottom: const
        automaticallyImplyLeading: false,
        title: Center(
          child: const Text(appTitle,
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Tajawal-b",
              )),
        ),
        toolbarHeight: 60,
        backgroundColor: Color(0xFF6db881),
      ),
      body: FirebaseAuth.instance.currentUser == null
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          SizedBox(height: 90),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 79),
              child: Text(
                "عذراً لابد من تسجيل الدخول ",
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Tajawal-b",
                    color: Color(0xFF6db881)),
                textAlign: TextAlign.center,
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF6db881)),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(27))),
            ),
            child: Text(
              "تسجيل الدخول",
              style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
            ),
          )
        ],
      )
          : const CustomForm(),
    );
  }
}




class CustomForm extends StatefulWidget {
  const CustomForm({super.key});

  @override
  CustomFormState createState() {
    return CustomFormState();
  }
}

class CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  int type = 1;
  String type1 = 'أماكن سياحية';
  void getCities() async {}
  String place_id = '';
  String city = "الرياض";
  String? address;
  final location = TextEditingController();
  final description = TextEditingController();
  final placeName = TextEditingController();
  final GlobalKey<FormFieldState> _AddressKey = GlobalKey<FormFieldState>();

  static get cancelButton => null;

  static get continueButton => null;

  @override
  void dispose() {
    location.dispose();
    description.dispose();
    placeName.dispose();
    super.dispose();
  }


  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedFiles = [];



  var citiesList = [
    "الرياض",
    "جدة",
  ];
  List areasList = [];


  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "إلغاء",
        style: TextStyle(
            fontFamily: "Tajawal-m",
            fontSize: 17,
            color: Color(0xFF6db881)
        ),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
        child: Text(
          "تأكيد",
          style: TextStyle(
            fontFamily: "Tajawal-m",
            fontSize: 17,
            color: Color(0xFF6db881),
          ),
        ),
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

          await FirebaseFirestore.instance.collection('addedPlaces').doc(place_id).set({
            'place_id': place_id,
            'User_id': userId,
            'placeName' : placeName,
            'city': city,
            'neighbourhood': address,
            'images': arrImage,
            'Location': location.text,
            'description': description.text,

          });
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
          });
        });


    //Navigator.push(
    //  context, MaterialPageRoute(builder: (context) => ThePlace()));


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
        "هل أنت متأكد من أنك تريد إضافة هذا المكان؟",
        style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
        textDirection: TextDirection.rtl,
      ),

      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        }
    );

    Fluttertoast.showToast(
      msg: "تمت اضافة المكان بنجاح",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: Color(0xFF6db881),
      textColor: Color(0xFF6db881),
      fontSize: 18.0,
    );

    // TODO: implement showDialog
    throw UnimplementedError();
  }

  @override


  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(width: double.infinity),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(margin: const EdgeInsets.all(10)),
                            Container(
                              child: Column(
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
                            ),
                            // More form fields and widgets here
                            // ...
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                // Additional content for the body
                // ...
              ),

              // Type selection section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 83, right: 25),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: placeName,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء عدم ترك الخانة فارغة!';
                            }
                            // Add more validation rules if needed.
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
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
                    padding: EdgeInsets.only(right:8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,

                      ),
                    ),
                    height: 50,
                    width: 150,


                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left:8),
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          child: Text(
                            "أماكن سياحية",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                          ),
                          value: 1,
                        ),
                        DropdownMenuItem<int>(
                          child: Text(
                            "مطاعم",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                          ),
                          value: 2,
                        ),
                        DropdownMenuItem<int>(
                          child: Text(
                            "مراكز تسوق",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: "Tajawal-m",
                              color: Color(0xFF6db881),
                            ),
                          ),
                          value: 3,
                        ),
                      ],
                        onChanged: (int? value) {
                          setState(() {
                            type = value!;
                            if (type == 1) type1 = 'أماكن سياحية';
                            if (type == 2) type1 = 'مطاعم';
                            if (type == 3) type1 = 'مراكز تسوق';

                          });
                        }
                    ),
                  ),
                  Text(
                    'تصنيف المكان: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Tajawal-b",
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),


              // City
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left:7), // Adjusted padding to right
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
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Tajawal-m",
                            color: Color(0xFF6db881),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(right:7),
                            hintText: 'اختر المدينة',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right:7),
                      ),
                      Padding(padding: EdgeInsets.only(left: 100, right: 50)),
                      Text(
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
                    padding: EdgeInsets.only(left: 7), // Adjusted padding to right
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Tajawal-m",
                        color: Color(0xFF6db881),
                      ),
                      decoration: InputDecoration(
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
                  Padding(padding: EdgeInsets.only(left: 100, right: 50)),
                  Text(
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
                      padding: EdgeInsets.only(left: 83, right: 25),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: description,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء عدم ترك الخانة فارغة!';
                            }
                            // Add more validation rules if needed.
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ':وصف للمكان ',
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
                      padding: EdgeInsets.only(left: 83, right: 25),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: location,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء عدم ترك الخانة فارغة!';
                            }
                            // Add more validation rules if needed.
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ':رابط لموقع المكان ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Tajawal-b",
                      ),
                    ),
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
                          child: Text(
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
                margin: const EdgeInsets.all(15),
              ),

              // Submit button
              SizedBox(
                width: 205.0,
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      getCities();

                      if (_formKey.currentState!.validate()) {
                        showAlertDialog(context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color(0xFF6db881)),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                    ),
                    child: const Text(
                      'إضافة',
                      style: TextStyle(
                          fontSize: 20, fontFamily: "Tajawal-m"),
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

  Future<String> uploadFile(XFile _image, String userId) async {
    FirebaseStorage imageRef = FirebaseStorage.instance;
    Reference reference = imageRef.ref().child(
        "placeImages/$userId/${_image.name}");
    File file = File(_image.path);
    await reference.putFile(file);
    String downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }


}