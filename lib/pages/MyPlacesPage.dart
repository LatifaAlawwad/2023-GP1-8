import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'placePage.dart';
import 'placeDetailsPage.dart';
import 'UserProfilePage.dart';
import 'package:gp/language_constants.dart';

class myPlacesPage extends StatefulWidget {
   String? selectedCategory;
   myPlacesPage({selectedCategory,Key? key}) : super(key: key);
  @override
  State<myPlacesPage> createState() => _myPlacesPage();
}
class _myPlacesPage extends State<myPlacesPage> {
  int indexOfTap = 0;
  List<placePage> accepted = [];
  List<placePage> rejected = [];
  List<placePage> pending = [];
  List<dynamic> userData = [];
  bool isDownloadedData = false;
  String name = '';
  String selectedCategory = 'طلبات بانتظار الاعتماد ';



  Map<String, String> collectionNames = {
    'طلبات معتمدة': 'ApprovedPlaces',
    'طلبات بانتظار الاعتماد': 'PendingPlaces',
    'طلبات مرفوضة': 'RejectedPlaces',
  };

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {

      accepted.clear();
      rejected.clear();
      pending.clear();
      String userid = getuser();

      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('ApprovedPlaces').get();
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((element) {
          final id = element.data()["User_id"];
          placePage place = placePage.fromMap(element.data());
          if (id == userid) {
            accepted.add(place);
          }
        });
      }


      QuerySnapshot<Map<String, dynamic>> snapshot2 =
      await FirebaseFirestore.instance.collection('RejectedPlaces').get();
      if (snapshot2.docs.isNotEmpty) {
        snapshot2.docs.forEach((element) {
          print(element.data()["User_id"]);
          final id = element.data()["User_id"];
          print("helooooooooooooooo");
          print(element.data()["User_id"]);
          placePage place = placePage.fromMap(element.data());
          if (id == userid) {
            rejected.add(place);
          }
        });
      }

      QuerySnapshot<Map<String, dynamic>> snapshot3 =
      await FirebaseFirestore.instance.collection('PendingPlaces').get();

      if (snapshot3.docs.isNotEmpty) {
        snapshot3.docs.forEach((element) {
          final id = element.data()["User_id"];
          placePage place = placePage.fromMap(element.data());

          if (id == userid) {
            pending.add(place);
          }
        });

      }

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 109, 184, 129),
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0,right:10.0),
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
                  translation(context).addRequest,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Tajawal-b",
                  ),
                ),
                SizedBox(width: 40), // Adjust the width based on your preference
              ],
            ),
            centerTitle: false,




            bottom: TabBar(

              labelStyle: TextStyle(
                fontFamily: "Tajawal-b",
                fontWeight: FontWeight.w100,
                fontSize: 13,
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
              onTap: (index) {
                indexOfTap = index;
                setState(() {
                  switch (index) {
                    case 0:
                      selectedCategory = 'طلبات معتمدة';
                      break;
                    case 1:
                      selectedCategory = 'طلبات بانتظار الاعتماد';
                      break;
                    case 2:
                      selectedCategory = 'طلبات مرفوضة';
                      break;
                  }
                });
              },
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: translation(context).approvedReq,
                ),
                Tab(
                  text: translation(context).waitingReq,
                ),
                Tab(
                  text: translation(context).rejectedReq,
                ),
              ],
            ),
          ),
          body:
          handleListItems(
            selectedCategory == 'طلبات معتمدة'
                ? accepted
                : selectedCategory == 'طلبات بانتظار الاعتماد'
                ? pending
                : selectedCategory == 'طلبات مرفوضة'
                ? rejected
                : [],
          ),
        ),
      ),
    );
  }

  Widget handleListItems(List<placePage> listItem) {

    return listItem.isNotEmpty
        ? ListView.separated(
      itemCount: listItem.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 10);
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

                    if (selectedCategory == 'طلبات بانتظار الاعتماد') // Show the delete icon only in this category
                      GestureDetector(
                        onTap: () {
                          showDeleteConfirmationDialog(place, selectedCategory);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    Expanded(child: Container()),
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


  void showDeleteConfirmationDialog(placePage place, String selectedCategory) {
    final buttonStyle = TextButton.styleFrom(
      primary: Color(0xFF6db881),
      textStyle: TextStyle(
        fontFamily: "Tajawal-m",
        fontSize: 17,
      ),
    );

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {


        return  AlertDialog(


          title: Text(translation(context).conDelete, textAlign: TextAlign.center,),
            content: Text("${translation(context).deletePlace}\n\n${place.placeName}", textAlign: TextAlign.center,),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Color(0xff11630e),
                    ),
                    child: Text(translation(context).cancel),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  if (selectedCategory == 'طلبات بانتظار الاعتماد')
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: Color(0xff11630e),
                      ),
                      child: Text(translation(context).delete),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        deletePlace(place.place_id);
                      },
                    ),
                ],
              ),
            ],
          );

      },
    ).then((result) {
      if (result != null && result && selectedCategory == 'طلبات بانتظار الاعتماد') {
        deletePlace(place.place_id);
      }
    });
  }

  Future<void> deletePlace(String place_id) async {
    try {
      await FirebaseFirestore.instance.collection("PendingPlaces").doc(place_id).delete();
      setState(() {
        pending.removeWhere((place) => place.place_id == place_id);
      });

      print("Updated lists.");
    } catch (e) {
      print("Error deleting place: $e");
    }
  }

  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  String getuser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var cpuid = user!.uid;
    return cpuid;
  }
}

