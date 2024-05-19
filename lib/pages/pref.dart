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
                backgroundColor: Color.fromARGB(255, 109, 184, 129),
                automaticallyImplyLeading: false,
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Text(
                            translation(context).chooseFav,
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: "Tajawal-b",
                            ),
                        ),
                        SizedBox(width: 40),
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

//for rest
    Map<String, Map<String, dynamic>> categoryData = {};

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
    void showAlertDialog(BuildContext context) {
        Widget cancelButton = TextButton(
            child: Text(
                translation(context).cancel,
                style: TextStyle(
                    fontFamily: "Tajawal-m",
                    fontSize: 17,
                    color: Color(0xFF6db881),
                ),
            ),
            onPressed: () {
                Navigator.of(context).pop();
            },
        );

        Widget continueButton = TextButton(
            child: Text(
                translation(context).agree,
                style: TextStyle(
                    fontFamily: "Tajawal-m",
                    color: Color(0xFF6db881),
                ),
            ),
            onPressed: () async {
                Navigator.of(context).pop();
                final FirebaseAuth auth = FirebaseAuth.instance;
                final User? user = auth.currentUser;
                final userId = user!.uid;
                List<String> arrImage = [];
                var uuid = const Uuid();

                // Iterate through all the checked categories
                for (var value in userChecked) {
                    String place_id = uuid.v4(); // Generate a unique ID for each category

                    switch (int.parse(value)) {
                        case 1:
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
                                "category": 'فعاليات و ترفيه',
                                "INorOUT": INorOUT,
                                "hasReservation": hasReservation,
                                'isTemporary': isTemporary,
                                'WebLink': WebLink.text,
                                'startDate': startDate,
                                'finishDate': finishDate,
                                'reservationDetails': reservationDetails,
                                'typeEnt': typeEnt,
                            });
                            break;
                        case 2:
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
                                "category": 'مطاعم',
                                'cuisine': cuisine,
                                'priceRange': priceRange,
                                'serves': serves,
                                'atmosphere': atmosphere,
                                'hasReservation': hasReservation,
                                'reservationDetails': reservationDetails,
                            });
                            break;
                        case 3:
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
                                "category": 'مراكز تسوق',
                                'hasCinema': hasCinema,
                                'INorOUT': INorOUT,
                                'hasFoodCourt': hasFoodCourt,
                                'hasPlayArea': hasPlayArea,
                                'hasSupermarket': hasSupermarket,
                                'shopType': shopType,
                            });
                            break;
                    // Add more cases for other categories if needed
                    }
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CitiesPage(),
                    ),
                );
            },
        );

        AlertDialog alert = AlertDialog(
            content: Text(
                translation(context).sureSaveFav,
                style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
            ),
            actions: [
                cancelButton,
                continueButton,
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
                    isSelected
                        ? userChecked.remove(value.toString())
                        : userChecked.add(value.toString()); // Toggle selection
                    if (type == 1)
                        categoryData['فعاليات و ترفيه'] = {
                            "INorOUT": INorOUT,
                            "hasReservation": hasReservation,
                            'isTemporary': isTemporary,
                            'WebLink': WebLink.text,
                            'startDate': startDate,
                            'finishDate': finishDate,
                            'reservationDetails': reservationDetails,
                            'typeEnt': typeEnt,
                        };
                    else if (type == 2)
                        categoryData['مطاعم'] = {
                            'cuisine': cuisine,
                            'priceRange': priceRange,
                            'serves': serves,
                            'atmosphere': atmosphere,
                            'hasReservation': hasReservation,
                            'reservationDetails': reservationDetails,
                        };
                    else if (type == 3)
                        categoryData['مراكز تسوق'] = {
                            'hasCinema': hasCinema,
                            'INorOUT': INorOUT,
                            'hasFoodCourt': hasFoodCourt,
                            'hasPlayArea': hasPlayArea,
                            'hasSupermarket': hasSupermarket,
                            'shopType': shopType,
                        };
                });
            },
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: isSelected ? Color(0xFF6db881) : Colors.white,
                    border: Border.all(
                        color: isSelected ? Color(0xFF6db881) : Colors.black54,
                        width: 1,
                    ),
                ),
                child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Tajawal-m',
                        color: isSelected ? Colors.white : Colors.black,
                    ),
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

        return Column(children: [
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
                            crossAxisAlignment: isArabic()
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                                const SizedBox(
                                    height: 10,
                                ),
                                Center(
                                    child: Text(
                                        translation(context).prefHeader,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                    ),
                                ),
                                const SizedBox(
                                    height: 10,
                                ),

                                RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Tajawal-b",
                                            color: Colors.black,
                                        ),
                                        children: [
                                            TextSpan(
                                                text: translation(context).categ,
                                            ),
                                        ],
                                    ),
                                ),

                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Wrap(
                                        spacing: 5,
                                        runSpacing: 7,
                                        alignment: isArabic()
                                            ? WrapAlignment.end
                                            : WrapAlignment.start,
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
                                        ],
                                    ),
                                ),

                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Wrap(
                                        spacing: 10,
                                        runSpacing: 7,
                                        alignment: isArabic()
                                            ? WrapAlignment.end
                                            : WrapAlignment.start,
                                        children: citiesList.map((value) {
                                            var temp;
                                            if (value == "Riyadh" || value == "الرياض")
                                                temp = "الرياض";
                                            else if (value == "Jeddah" || value == "جدة")
                                                temp = "جدة";

                                            bool isSelected = city == temp;
                                            bool isSelectable =
                                            !['العلا', 'الشرقية'].contains(value);
                                            return GestureDetector(
                                                onTap: isSelectable
                                                    ? () async {
                                                    var tempCity = await cities.where(
                                                            (element) =>
                                                        (element['name_ar'] == value ||
                                                            element['name_en'] == value));

                                                    setState(() {
                                                        city = tempCity.first['name_ar'];
                                                    });
                                                }
                                                    : null,
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 15,
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

/////////////////////////////////new attr////////////////////////////////////////////////

                                if (type == 1)
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: isArabic()
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
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
                                                            text: translation(context).entType,
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(top: 10),
                                                child: Wrap(
                                                    spacing: 10,
                                                    runSpacing: 7,
                                                    alignment: isArabic()
                                                        ? WrapAlignment.end
                                                        : WrapAlignment.start,
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
                                                                        width: 1,
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
                                        crossAxisAlignment: isArabic()
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
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
                                                            text: translation(context).cuisine,
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Container(
                                                alignment: isArabic()
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
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
                                                        contentPadding: EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 15),
                                                    ),
                                                    iconSize: 0,
                                                    isExpanded: true,
                                                    onChanged: (String? newValue) {
                                                        setState(() {
                                                            cuisine.add(
                                                                newValue!); // Add the selected cuisine to the list
                                                        });
                                                    },
                                                    hint: Text(
                                                        translation(context).foodType,
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
                                                alignment: isArabic()
                                                    ? WrapAlignment.end
                                                    : WrapAlignment.start,
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
                                                                mainAxisAlignment: isArabic()
                                                                    ? MainAxisAlignment.end
                                                                    : MainAxisAlignment.start,
                                                                children: [
                                                                    const SizedBox(width: 25),
                                                                    Text(
                                                                        serve,
                                                                        style: const TextStyle(
                                                                            fontSize: 16.0,
                                                                            fontFamily: 'Tajawal-m'),
                                                                    ),
                                                                    const SizedBox(width: 5),
                                                                    serves.contains(serve)
                                                                        ? const Icon(
                                                                        Icons.check_rounded,
                                                                        size: 16,
                                                                        color: Color(0xFF6db881),
                                                                    )
                                                                        : const SizedBox(width: 16),
                                                                    const SizedBox(width: 5),
                                                                ],
                                                            ),
                                                        ),
                                                    );
                                                }).toList(),
                                            ),
                                            const SizedBox(height: 20),

//  the CheckBoxes for 'atmosphere'
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
                                                alignment: isArabic()
                                                    ? WrapAlignment.end
                                                    : WrapAlignment.start,
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
                                        crossAxisAlignment: isArabic()
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                            const SizedBox(height: 20),
                                            Text(
                                                translation(context).storeType,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: "Tajawal-b",
                                                ),
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                                spacing: 10,
                                                runSpacing: 7,
                                                alignment: isArabic()
                                                    ? WrapAlignment.end
                                                    : WrapAlignment.start,
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
                                const SizedBox(
                                    height: 20,
                                ),
                            ])))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
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
                        child: Text(
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
                    content: Text(
                        translation(context).fill,
                        style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
//textDirection: TextDirection.rtl,
                    ),
                    actions: [
                        TextButton(
                            child: Text(translation(context).agree),
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