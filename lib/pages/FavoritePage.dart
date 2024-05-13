import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Registration/logIn.dart';
import 'placePage.dart';
import 'placeDetailsPage.dart';
import 'package:gp/language_constants.dart';

class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePage();
}

class _FavoritePage extends State<FavoritePage> {
  List<placePage> favoriteList = [];
  late String userId;

  @override
  void initState() {
    super.initState();

    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      favoriteList.clear();
      userId = getuser();

      // Fetch 'place_id' values from 'Favorite' collection
      QuerySnapshot<Map<String, dynamic>> favoriteSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('Favorite')
              .get();

      List<String> favoritePlaceIds = favoriteSnapshot.docs
          .map((element) => element.data()["place_id"] as String)
          .toList();

      // Fetch places from 'ApprovedPlaces' collection that match 'place_id'
      QuerySnapshot<Map<String, dynamic>> approvedPlacesSnapshot =
          await FirebaseFirestore.instance
              .collection('ApprovedPlaces')
              .where('place_id', whereIn: favoritePlaceIds)
              .get();

      // Identify the place_ids that no longer exist in 'ApprovedPlaces'
      List<String> existingPlaceIds = approvedPlacesSnapshot.docs
          .map((element) => element.data()["place_id"] as String)
          .toList();

      // Remove non-existing place_ids from 'Favorite' collection
      List<QueryDocumentSnapshot<Map<String, dynamic>>> nonExistingPlaces =
          favoriteSnapshot.docs
              .where((element) => !existingPlaceIds
                  .contains(element.data()["place_id"] as String))
              .toList();

      // Delete non-existing places from 'Favorite' collection
      nonExistingPlaces.forEach((document) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('Favorite')
            .doc(document.id)
            .delete();
      });

      // Add fetched places to 'favoriteList'
      if (approvedPlacesSnapshot.docs.isNotEmpty) {
        approvedPlacesSnapshot.docs.forEach((element) {
          placePage place = placePage.fromMap(element.data());
          favoriteList.add(place);
        });
      }

      // Update the UI
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget handleListItems(List<placePage> listItem) {
    return listItem.isNotEmpty
        ? Expanded(
            child: ListView.separated(
              itemCount: listItem.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 0);
              },
              itemBuilder: (BuildContext context, int index) {
                if (listItem[index] is placePage) {
                  return _buildItem(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              placeDetailsPage(place: listItem[index]),
                        ),
                      );
                    },
                    listItem[index] as placePage,
                    context,
                  );
                }
                return Container();
              },
            ),
          )
        : Center(
            child: Text(
             translation(context).noResults,
              style: TextStyle(
                color: Color(0xFF6db881),
                fontSize: 16,
              ),
            ),
          );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getFav(String id) {
    Future<QuerySnapshot<Map<String, dynamic>>> snapshot = FirebaseFirestore
        .instance
        .collection('users')
        .doc(id)
        .collection('Favorite')
        .get();
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title:  Text(
            translation(context).favPage,
            style: TextStyle(
              fontSize: 17,
              fontFamily: "Tajawal-b",
            ),
          ),
        centerTitle: true,
        toolbarHeight: 60,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currentUser != null)
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: getFav(userId),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                ) {
                  return handleListItems(favoriteList);
                },
              ),
            if (currentUser == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 79),
                      child: Text(
                        translation(context).reqLogin,
                        style: TextStyle(
                          fontSize: 18,

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
                        translation(context).login,
                        style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
                    // Favorite icon at the top left corner
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
                            icon: (Icon(
                              Icons.favorite,
                            )),
                            color: Colors.red,
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
                                      constraints:
                                          BoxConstraints(maxHeight: 30),
                                      alignment: Alignment.center,
                                      child: Text(
                                        translation(context).removeFavList,
                                        style: TextStyle(
                                          color: Color(0xff424242),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          primary: Color(0xff11630e),
                                        ),
                                        child: Text(translation(context).no),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            favoriteList.remove(place);
                                          });

                                          try {
                                            // Delete from Firestore
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .collection('Favorite')
                                                .doc(place.place_id)
                                                .delete();
                                          } catch (e) {
                                            // Handle any errors
                                            debugPrint(e.toString());
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          primary: Color(0xff11630e),
                                        ),
                                        child: Text(translation(context).yes),
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ' ${place.placeName}',
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

                                        double averageRating = ratings
                                                .isNotEmpty
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
                                                  index < averageRating.floor()
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
}
