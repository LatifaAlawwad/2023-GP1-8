import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gp/Registration/logIn.dart';
import 'package:gp/helper/CustomRadioButton.dart';
import 'package:gp/helper/MapViewDrop.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'neighbourhood.dart';
import 'cities.dart';
import 'HomePage.dart';
import 'citiesPage.dart';
import 'package:gp/language_constants.dart';

class pref extends StatefulWidget {
    const pref({Key? key}) : super(key: key);
    @override
    State<pref> createState() => _pref();
}

class _pref extends State<pref> {
    GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 109, 184, 129),
                automaticallyImplyLeading: false,
                title:  Padding(
                    padding: EdgeInsets.only(left: 150),
                    child: Text(
                        translation(context).chooseFav,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
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
                            child:  Text(
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
            child:  Text(
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
            content:  Text(
                translation(context).sureSaveFav ,
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
                        var uuid = const Uuid();
                        place_id = uuid.v4();
                        if (type1 == 'فعاليات و ترفيه') {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('prefrences')
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
                                "INorOUT": INorOUT,
                                "hasReservation": hasReservation,
                                'isTemporary': isTemporary,
                                'WebLink': WebLink.text,
                                'startDate': startDate,
                                'finishDate': finishDate,
                                'reservationDetails': reservationDetails,
                                'typeEnt': typeEnt,
                            });
/* await FirebaseFirestore.instance \
.collection('users') \
.doc(userId) \
.update({
    "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
});*/
                            setState(() {
                                HomePageState.isDownloadedData = false;
                            });
                        } else if (type1 == 'مطاعم') {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('prefrences')
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
                                'cuisine': cuisine,
                                'priceRange': priceRange,
                                'serves': serves,
                                'atmosphere': atmosphere,
                                'hasReservation': hasReservation,
                                'reservationDetails': reservationDetails,
                            });
/*await FirebaseFirestore.instance \
.collection('users') \
.doc(userId) \
.update({
    "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
});*/
                            setState(() {
                                HomePageState.isDownloadedData = false;
                            });
                        } else if (type1 == 'مراكز تسوق') {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('prefrences')
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
                                'hasCinema': hasCinema,
                                'INorOUT': INorOUT,
                                'hasFoodCourt': hasFoodCourt,
                                'hasPlayArea': hasPlayArea,
                                'hasSupermarket': hasSupermarket,
                                'shopType': shopType,
                            });
/*await FirebaseFirestore.instance \
.collection('users') \
.doc(userId) \
.update({
    "ArrayOfPlaces": FieldValue.arrayUnion([place_id])
});*/
                            setState(() {
                                HomePageState.isDownloadedData = false;
                            });
                        } else if (type1 == null) {
// If no category is selected, you can set a default display attribute here

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('prefrences')
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
                            });
                        }

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CitiesPage(),
                            ),
                        );
                    },
                    child:  Text(
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

    Widget _buildPlaceTypeBox({
        required String title,
        required int value,
    }) {
        bool isSelected = type == value;

        return GestureDetector(
            onTap: () {
                setState(() {
                    type = value;
                    if (type == 1)
                        type1 = 'فعاليات و ترفيه';
                    else if (type == 2)
                        type1 = 'مطاعم';
                    else if (type == 3) type1 = 'مراكز تسوق';
                });
            },
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: isSelected ? const Color(0xFF6db881) : Colors.white,
                    border: Border.all(
                        color: isSelected ? const Color(0xFF6db881) : Colors.black54,
                        width: 1, // Adjust border width
                    ),
                ),
                child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 17.0,
                        fontFamily: "Tajawal-m",
                        color: isSelected ? Colors.white : const Color(0xFF6db881),
                    ),
                    textAlign: TextAlign.end,
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        var citiesList = [
            translation(context).riyadh,
            translation(context).jeddah,
        ];
        List<String> shopOptions = [
            translation(context).clothingEM,
            translation(context).shoesEM,
            translation(context).bagsEM,
            translation(context).furnitureEM,
            translation(context).electronicsEM,
            translation(context).utensilsEM,
            translation(context).perfumesEM,
            translation(context).abayasEM,
            translation(context).jewelryEM,
            translation(context).children_clothingEM,
            translation(context).cosmeticsEM,
            translation(context).pharmaciesEM,
            translation(context).otherEM,
        ];
        List<String> cuisineOptions = [
            translation(context).saudiEM,
            translation(context).italianEM,
            translation(context).americanEM,
            translation(context).asianEM,
            translation(context).indianEM,
            translation(context).mexicanEM,
            translation(context).turkishEM,
            translation(context).seafoodEM,
            translation(context).spanishEM,
            translation(context).middle_easternEM,
            translation(context).greekEM,
            translation(context).bakeryEM,
            translation(context).internationalEM,
            translation(context).healthyEM,
            translation(context).coffee_and_dessertsEM,
        ];
        List<String> typeEntOptions = [
            translation(context).sports_and_adventuresEM,
            translation(context).artsEM,
            translation(context).historical_landmarksEM,
            translation(context).cultureEM,
            translation(context).parks_and_gardensEM,
            translation(context).amusement_parksEM,
            translation(context).exhibitionsEM,
        ];
        List<String> servesOptions = [
            translation(context).breakfastEM,
            translation(context).lunchEM,
            translation(context).dinnerEM,
        ];
        List<String> atmosphereOptions = [
            translation(context).musicEM,
            translation(context).quietEM,
            translation(context).beachsideEM,
            translation(context).indoorEM,
            translation(context).outdoorEM,
        ];

        return Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
                child: Container(
                    margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                    padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
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
                                                text: translation(context).categ,
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
                                    child: Wrap(
                                        spacing: 5,
                                        runSpacing: 7,
                                        alignment: WrapAlignment.end,
                                        children: [
                                            _buildPlaceTypeBox(
                                                title: translation(context).entEmoji,
                                                value: 1,
                                            ),
                                            _buildPlaceTypeBox(
                                                title: translation(context).restEmoji,
                                                value: 2,
                                            ),
                                            _buildPlaceTypeBox(
                                                title: translation(context).mallEmoji,
                                                value: 3,
                                            ),
                                        ],
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
                                    child: Wrap(
                                        spacing: 10,
                                        runSpacing: 7,
                                        alignment: WrapAlignment.end,
                                        children: citiesList.map((value) {
                                            bool isSelected = city == value;
                                            bool isSelectable =
                                            !['العلا', 'الشرقية'].contains(value);
                                            return GestureDetector(
                                                onTap: isSelectable
                                                    ? () async {
                                                    var tempCity = await cities.where(
                                                            (element) =>
                                                        (element['name_ar'] == value));
                                                    var tempArea = await areas.where(
                                                            (element) => (element['city_id'] ==
                                                            tempCity.first['city_id']));
                                                    areasList.clear();
                                                    areasList.addAll(tempArea);
                                                    setState(() {
                                                        city = value;
                                                    });
                                                }
                                                    : null,
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 15,
                                                    ),
                                                    margin: const EdgeInsets.only(
                                                        bottom: 10,
                                                        right: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.all(Radius.circular(10)),
                                                        color: Colors.white, // Set the color to white
                                                        border: Border.all(
                                                            color: isSelected
                                                                ? const Color(0xFF6db881)
                                                                : Colors.black54,
                                                            width: 1,
                                                        ),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                            Text(
                                                                value,
                                                                style: TextStyle(
                                                                    fontSize: 16.0,
                                                                    fontFamily: 'Tajawal-m',
                                                                    color: isSelected
                                                                        ? const Color(0xFF6db881)
                                                                        : Color(0xFF6db881),
                                                                ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            if (isSelected)
                                                                Icon(
                                                                    Icons.check_rounded,
                                                                    size: 16,
                                                                    color: const Color(0xFF6db881),
                                                                ),
                                                        ],
                                                    ),
                                                ),
                                            );
                                        }).toList(),
                                    ),
                                ),

// Text('ساعات العمل في أيام الأسبوع: $weekdaysWorkingHr'),

/////////////////////////////////new attr////////////////////////////////////////////////

                                if (type == 1)
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                            Text(
                                                translation(context).entType,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: "Tajawal-b",
                                                ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(top: 10),
                                                child: Wrap(
                                                    spacing: 10,
                                                    runSpacing: 7,
                                                    alignment: WrapAlignment.end,
                                                    children: typeEntOptions.map((value) {
                                                        bool isSelected = typeEnt == value;
                                                        return GestureDetector(
                                                            onTap: () {
                                                                setState(() {
                                                                    typeEnt = value;
                                                                });
                                                            },
                                                            child: Container(
                                                                padding: const EdgeInsets.symmetric(
                                                                    vertical: 10, horizontal: 15),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: const BorderRadius.all(
                                                                        Radius.circular(10)),
                                                                    color: Colors.white,
                                                                    border: Border.all(
                                                                        color: isSelected
                                                                            ? const Color(0xFF6db881)
                                                                            : Colors.black,
                                                                        width: 1, // Adjust border width
                                                                    ),
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.center,
                                                                    children: [
                                                                        Text(
                                                                            value,
                                                                            style: TextStyle(
                                                                                fontSize: 16.0,
                                                                                fontFamily: 'Tajawal-m',
                                                                                color: isSelected
                                                                                    ? const Color(0xFF6db881)
                                                                                    : Colors.black,
                                                                            ),
                                                                        ),
                                                                        if (isSelected)
                                                                            const Icon(
                                                                                Icons.check,
                                                                                color: Color(0xFF6db881),
                                                                            ),
                                                                    ],
                                                                ),
                                                            ),
                                                        );
                                                    }).toList(),
                                                ),
                                            ),
                                            const SizedBox(height: 20),
                                            Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [],
                                            ),
                                        ],
                                    ),

                                if (type == 2) // Check if the type is for مطاعم
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
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
                                                            Icons
                                                                .arrow_drop_down, // Set your desired icon
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
                                                    hint:  Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Text(
                                                            translation(context).foodType,
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
                                            Text(
                                                translation(context).meals,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: "Tajawal-b",
                                                    color:
                                                    Colors.black, // Set the text color to black
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
                                                    color:
                                                    Colors.black, // Set the text color to black
                                                ),
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                                spacing: 10,
                                                runSpacing: 7,
                                                alignment: WrapAlignment.end,
                                                children: atmosphereOptions
                                                    .map((atmosphereOptionsWithIcons) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                            setState(() {
                                                                if (atmosphere.contains(
                                                                    atmosphereOptionsWithIcons)) {
                                                                    atmosphere
                                                                        .remove(atmosphereOptionsWithIcons);
                                                                } else {
                                                                    atmosphere
                                                                        .add(atmosphereOptionsWithIcons);
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
                                                                    color: atmosphere.contains(
                                                                        atmosphereOptionsWithIcons)
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
                                                                    Text(atmosphereOptionsWithIcons,
                                                                        style: const TextStyle(
                                                                            fontSize: 16.0,
                                                                            fontFamily: 'Tajawal-m')),
                                                                    const SizedBox(
                                                                        width: 5,
                                                                    ),
                                                                    atmosphere.contains(
                                                                        atmosphereOptionsWithIcons)
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

                                if (type == 3)
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
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
                                        ],
                                    ),
                            ])))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: ElevatedButton(
                        onPressed: () async {
                            showAlertDialog(context);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(const Color(0xFF6db881)),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                ),
                            ),
                        ),
                        child:  Text(
                            translation(context).next,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Tajawal-m",
                            ),
                        ),
                    ),
                ),
            ),
        ]);
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
                    content:  Text(
                        translation(context).fill,
                        style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
//textDirection: TextDirection.rtl,
                    ),
                    actions: [
                        TextButton(
                            child:  Text(translation(context).agree),
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