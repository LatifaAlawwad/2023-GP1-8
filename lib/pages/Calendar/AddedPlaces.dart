import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../cities.dart';
import '../neighbourhood.dart';
import 'SearchPlacesPage.dart';
import '../placePage.dart';
import '../placeDetailsPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/language_constants.dart';

class AddPlacesMessagePage extends StatefulWidget {
  final DateTime selectedDay;
  final String? cityName;

  const AddPlacesMessagePage({Key? key, required this.selectedDay,this.cityName}) : super(key: key);

  @override
  _AddPlacesMessagePageState createState() => _AddPlacesMessagePageState();
}

class _AddPlacesMessagePageState extends State<AddPlacesMessagePage> {
  List<String> selectedPlaces = [];
  late String userId; // Declare the userId variable

  @override
  void initState() {
    super.initState();
    userId = getuser(); // Initialize the userId using the getuser method
  }
  @override
  Widget build(BuildContext context) {
    DateTime dateOnly = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    bool isPastDate = dateOnly.isBefore(currentDate);
    bool isTodayOrFuture = !isPastDate;

    Timestamp startTimestamp = Timestamp.fromDate(dateOnly);
    Timestamp endTimestamp = Timestamp.fromDate(dateOnly.add(Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
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
              "${translation(context).placesADD} ${DateFormat('yyyy-MM-dd').format(dateOnly)}",
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Tajawal-b",
              ),
            ),
            SizedBox(width: 40), // Adjust the width based on your preference
          ],
        ),
        centerTitle: false,
        toolbarHeight: 60,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendar')
            .where('SelectedDay',
            isEqualTo: DateFormat('yyyy-MM-dd').format(widget.selectedDay)) // Compare formatted dates
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Clear the existing selectedPlaces list
            selectedPlaces.clear();

            // Loop through each document in the snapshot
            for (var doc in snapshot.data!.docs) {
              // Check if the document contains the 'places' array
              if (doc['places'] != null) {
                // Get the 'places' array from the document
                List<dynamic> placesArray = doc['places'];

                // Add each place ID from the array to selectedPlaces list
                selectedPlaces.addAll(placesArray.map((placeId) => placeId.toString()));
              }
            }

            if (selectedPlaces.isEmpty) {
              // If no added places for any date
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isTodayOrFuture
                          ? translation(context).addWantedPlaces
                          : translation(context).noADDplaces,
                      style: TextStyle(
                        color: Color(0xFF6db881),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: selectedPlaces.length,
              itemBuilder: (context, index) {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('ApprovedPlaces')
                      .where('place_id', isEqualTo: selectedPlaces[index])
                      .get(),
                  builder: (context, placeSnapshot) {
                    if (placeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (placeSnapshot.hasError) {
                      return Text('Error fetching place details');
                    }

                    if (placeSnapshot.hasData &&
                        placeSnapshot.data!.docs.isNotEmpty) {
                      var document = placeSnapshot.data!.docs.first;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => placeDetailsPage(
                                place: placePage.fromMap(
                                    document.data() as Map<String, dynamic>),
                              ),
                            ),
                          );
                        },
                        child: _buildItem(
                          placePage.fromMap(
                              document.data() as Map<String, dynamic>),
                          context,
                        ),
                      );
                    }

                    return Text('');
                  },
                );
              },
            );
          } else {
            // If no added places for any date
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isTodayOrFuture
                        ?  translation(context).addWantedPlaces
                        : translation(context).noADDplaces,
                    style: TextStyle(
                      color: Color(0xFF6db881),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: isTodayOrFuture
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPlacesPage(
                dateonly: widget.selectedDay,
                cityName: widget.cityName,
              ),
            ),
          );
        },
        backgroundColor:
        Color.fromARGB(255, 109, 184, 129), // Set the background color
        child: Icon(Icons.add, color: Colors.white), // Set the icon color
      )
          : null, // Disable the FAB if it's a past date
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }




  String getNeighbourhoodEnName(String arabicName) {
    for (var area in areas) {
      if (area["name_ar"] == arabicName) {
        return area["name_en"];
      }
    }
    return "Name not found"; // Or handle the case where name is not found
  }




  String getCityEnName(String arabicName) {
    for (var city in cities) {
      if (city["name_ar"] == arabicName) {
        return city["name_en"];
      }
    }
    return "Name not found"; // Or handle the case where name is not found
  }

Widget _buildItem(placePage place, BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Stack(
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              image: place.images.isEmpty
                  ? DecorationImage(
                image: NetworkImage(
                    'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'),
                fit: BoxFit.cover,
              )
                  : DecorationImage(
                image: NetworkImage(place.images[0]),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: isArabic()? CrossAxisAlignment.start: CrossAxisAlignment.end,
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 234, 250, 236),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IconButton(
                          alignment: Alignment.center,
                          icon: Icon(
                            Icons.calendar_month,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    translation(context).conRemove,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xff383737),
                                    ),
                                  ),
                                  content: Container(
                                    constraints: BoxConstraints(maxHeight: 50),
                                    alignment: Alignment.center,
                                    child: Text(
                                      translation(context).removeList,
                                      style: TextStyle(
                                        color: Color(0xff424242),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: TextButton.styleFrom(
                                            primary: Color(0xff11630e),
                                          ),
                                          child: Text(translation(context).no),
                                        ),
                                        SizedBox(width: 20),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            setState(() {});

                                            await deletePlaceFromCalendar(place.place_id, widget.selectedDay);
                                          },
                                          style: TextButton.styleFrom(
                                            primary: Color(0xff11630e),
                                          ),
                                          child: Text(translation(context).yes),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Expanded(child: Container()),
                  // Existing code for displaying place details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${place.placeName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Tajawal-l",
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: isArabic()
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'?'${place.neighbourhood} ، ${place.city}' :' ${getNeighbourhoodEnName(place.neighbourhood)}, ${getCityEnName(place.city)} ',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Tajawal-l",
                        ),
                      ),
                      Spacer(),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('ApprovedPlaces')
                            .doc(place.place_id)
                            .collection('Reviews')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          List<double> ratings = List<double>.from(
                            snapshot.data!.docs.map((doc) {
                              final commentData = doc.data()
                              as Map<String, dynamic>;
                              return commentData["rating"].toDouble() ?? 0.0;
                            }),
                          );

                          double averageRating = ratings.isNotEmpty
                              ? ratings.reduce((a, b) => a + b) /
                              ratings.length
                              : 0.0;

                          return Row(
                            children: [
                              for (int index = 0; index < 5; index++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Icon(
                                    index < averageRating.floor()
                                        ? Icons.star
                                        : index + 0.5 == averageRating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                    color: const Color.fromARGB(
                                        255, 109, 184, 129),
                                    size: 20.0,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
   deletePlaceFromCalendar(String placeId, DateTime selectedDay) async {
    try {
      String userId = getuser();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendar')
          .doc(DateFormat('yyyy-MM-dd').format(selectedDay))
          .update({
        'places': FieldValue.arrayRemove([placeId]),
      });

      Fluttertoast.showToast(
        msg: translation(context).succDeletePlace,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      debugPrint('Error deleting place: $e');
    }
  }

}

String getuser() {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;
  var cpuid = user!.uid;
  return cpuid;
}

