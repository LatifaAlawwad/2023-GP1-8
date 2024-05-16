import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gp/language_constants.dart';
import '../placePage.dart'; // Import placePage.dart if necessary
import '../placeDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/language_constants.dart';


class SearchPlacesPage extends StatefulWidget {
  final DateTime dateonly;

  const SearchPlacesPage({Key? key, required this.dateonly}) : super(key: key);

  @override
  _SearchPlacesPageState createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends State<SearchPlacesPage> {
  TextEditingController searchController = TextEditingController();
  List<placePage> suggestions = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _getAllPlaces();
  }

  void _getAllPlaces() {
    FirebaseFirestore.instance
        .collection('ApprovedPlaces')
        .get()
        .then((snapshot) {
      setState(() {
        suggestions = snapshot.docs
            .map((doc) => placePage.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    });
  }

  Widget _buildItem(
      void Function()? onTap,
      placePage place,
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                              Icons.add,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              String userId = getuser();
                              print('User ID: $userId'); // Check if the user ID is retrieved correctly

                              if (userId.isNotEmpty) {
                                DateTime selectedDate = widget.dateonly;
                                String formattedDate = selectedDate.toIso8601String().split('T')[0];
                                print('Formatted Date: $formattedDate'); // Check the formatted date

                                // Check if the place is already added for the selected day
                                bool placeExists = await checkIfPlaceExists(userId, place.place_id, formattedDate);
                                print('Place Exists: $placeExists'); // Check the result of placeExists

                                if (placeExists) {
                                  // Show toast message indicating that the place is already added
                                  Fluttertoast.showToast(
                                    msg: translation(context).alreadyAdded,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                } else {
                                  try {
                                    // Add the place to the database
                                    var calendarDocRef = FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .collection('calendar')
                                        .doc(formattedDate);

                                    // Get the existing data from the document
                                    var docSnapshot = await calendarDocRef.get();

                                    // Check if the document already exists
                                    if (docSnapshot.exists) {
                                      // Update the existing document by adding the new place ID to the 'places' array
                                      await calendarDocRef.update({
                                        'places': FieldValue.arrayUnion([place.place_id]),
                                        // Add other relevant data
                                      });
                                    } else {
                                      // Create a new document with the 'places' array containing the new place ID
                                      await calendarDocRef.set({
                                        'SelectedDay': formattedDate,
                                        'places': [place.place_id],
                                        // Add other relevant data
                                      }
                                      );
                                    }

                                    // Show toast message indicating successful addition
                                    Fluttertoast.showToast(
                                      msg: translation(context).succAdded,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  } catch (e) {
                                    print('Error adding place to calendar: $e');
                                  }
                                }
                              }
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
                              '${place.neighbourhood} ، ${place.city}',
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
      ),
    );
  }

  String getuser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var cpuid = user!.uid;
    return cpuid;
  }
  void _getSuggestions(String query) {
    query = query.trim();
    suggestions.clear();

    if (query.isEmpty) {
      // Fetch all places if the search query is empty
      _getAllPlaces();
    } else {
      FirebaseFirestore.instance
          .collection('ApprovedPlaces')
          .get()
          .then((snapshot) {
        setState(() {
          suggestions = snapshot.docs
              .map((doc) => placePage.fromMap(doc.data() as Map<String, dynamic>))
              .where((place) =>
              place.placeName.toLowerCase().contains(query.toLowerCase()))
              .toList();

          // Sort the suggestions based on the order of letters.
          suggestions.sort((a, b) {
            final formattedA = a.placeName.replaceAll(' ', '').toLowerCase();
            final formattedB = b.placeName.replaceAll(' ', '').toLowerCase();
            final formattedQuery = query.toLowerCase();
            return formattedA.indexOf(formattedQuery) -
                formattedB.indexOf(formattedQuery);
          });
        });
      });
    }
  }




  Future<bool> checkIfPlaceExists(
      String userId, String placeId, String selectedDate) async {
    bool placeExists = false;
    try {
      // Get the document reference for the user's calendar on the selected date
      var calendarDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendar')
          .doc(selectedDate);

      var docSnapshot = await calendarDocRef.get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        // Check if the 'places' array contains the placeId
        if (data != null && data['places'] != null) {
          List<dynamic> places = data['places'];
          placeExists = places.contains(placeId);
        }
      }
    } catch (e) {
      print('Error checking if place exists: $e');
    }
    return placeExists;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [


            Padding(
              padding: EdgeInsets.only(right: 20.0),
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

            Icon(
              Icons.search,
              color: Colors.white,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  _getSuggestions(value);
                },
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 17, 99, 14)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  alignLabelWithHint: true,
                  hintText: translation(context).search,
                  hintStyle: TextStyle(
                    color: Color.fromARGB(143, 255, 255, 255),
                    fontFamily: "Tajawal-m",
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        toolbarHeight: 60,



      ),


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return _buildItem(
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => placeDetailsPage(
                            place: suggestions[index],
                          ),
                        ),
                      );
                    },
                    suggestions[index],
                    context,
                  );
                },
              ),
            ),
          if (suggestions.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  translation(context).noResults,
                  style: TextStyle(
                    color: Color(0xFF6db881),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),


    );
  }
}