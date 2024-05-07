import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../placePage.dart'; // Import placePage.dart if necessary
import '../placeDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129), // Custom color
        automaticallyImplyLeading: false, // Remove back button
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white), // Search icon
              onPressed: () {
                setState(() {
                  isSearching = !isSearching; // Toggle search mode
                  searchController.clear(); // Clear the search text field
                  suggestions.clear(); // Clear search suggestions
                });
              },
            ),
            Expanded(
              child: isSearching
                  ? TextField(
                controller: searchController,
                onChanged: (value) {
                  _getSuggestions(value);
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن اسم المكان',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              )
                  : Padding(
                padding: const EdgeInsets.only(left: 70),
                child: Text(
                  "البحث عن الأماكن",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Tajawal-b",
                    color: Colors.white, // Text color added
                  ),
                ),
              ),
            ),

          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Handle navigation action
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


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add search results widget here
          if (suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return _buildItem(
                        () {
                      // Navigate to place details page on tap
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
        ],
      ),
    );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (userId.isNotEmpty) {
                                // Convert dateonly to Firestore date format
                                DateTime selectedDate = widget.dateonly;
                                String formattedDate = selectedDate.toIso8601String().split('T')[0];

                                // Check if the place is already added for the selected day
                                bool placeExists = await checkIfPlaceExists(userId, place.place_id, formattedDate);

                                if (placeExists) {
                                  // Show toast message indicating that the place is already added
                                  Fluttertoast.showToast(
                                    msg: 'المكان مضاف بالفعل لهذا التاريخ',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                } else {
                                  // Add place to calendar collection with formatted date
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('calendar')
                                      .doc(place.place_id)
                                      .set({
                                    'SelectedDay': formattedDate,
                                    'place_id': place.place_id,
                                    // Add other relevant data
                                  });

                                  // Show toast message indicating successful addition
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
                          ),
                        ),
                      ),
                    ),

                    Expanded(child: Container()),

                    // Existing code for displaying place details
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${place.placeName}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  height: 2,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-l",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: StreamBuilder<QuerySnapshot>(
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

                                        List<double> ratings =
                                        List<double>.from(
                                          snapshot.data!.docs.map((doc) {
                                            final commentData = doc.data()
                                            as Map<String, dynamic>;
                                            return commentData["rating"]
                                                .toDouble() ??
                                                0.0;
                                          }),
                                        );

                                        double averageRating = ratings.isNotEmpty
                                            ? ratings.reduce((a, b) => a + b) /
                                            ratings.length
                                            : 0.0;

                                        return Row(
                                          children: [
                                            for (int index = 0;
                                            index < 5;
                                            index++)
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 2.0),
                                                child: Icon(
                                                  index <
                                                      averageRating.floor()
                                                      ? Icons.star
                                                      : index + 0.5 ==
                                                      averageRating
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
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${place.neighbourhood} ، ${place.city}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Tajawal-l",
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
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

    FirebaseFirestore.instance
        .collection('ApprovedPlaces')
        .where('placeName', isGreaterThanOrEqualTo: query)
        .get()
        .then((snapshot) {
      setState(() {
        suggestions = snapshot.docs
            .map((doc) => placePage.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    });
  }
  Future<bool> checkIfPlaceExists(String userId, String placeId, String selectedDate) async {
    bool placeExists = false;
    try {
      // Check if the place document exists for the selected day
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendar')
          .doc(placeId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        // Check if the SelectedDay field matches the selected date
        if (data != null && data['SelectedDay'] == selectedDate) {
          placeExists = true;
        }
      }
    } catch (e) {
      print('Error checking if place exists: $e');
    }
    return placeExists;
  }

}