import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'placePage.dart';

import 'placeDetailsPage.dart';
import 'UserProfilePage.dart';

class myPlacesPage extends StatefulWidget {


  const myPlacesPage({Key? key}) : super(key: key);
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
  String selectedCategory = 'تجارب معتمدة';

  List<placePage> searchResults = [];

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
      await FirebaseFirestore.instance.collection('addedPlaces').get();
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
          final id = element.data()["User_id"];
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



  Widget handleListItems(List<placePage> listItem) {
    return ListView.separated(
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
                    builder: (context) => placeDetailsPage(place: listItem[index])),
              );
            },
            listItem[index] as placePage,
            context,
          );
        }
        return Container();
      },
    );
  }

  Widget _buildItem(void Function()? onTap, placePage place, BuildContext context) {

    if (  selectedCategory == 'تجارب معتمدة'
        || selectedCategory == 'تجارب بانتظار الاعتماد'
        || selectedCategory == 'تجارب مرفوضة' ) {
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
          child: Container(
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    width: 85,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showDeleteConfirmationDialog(place, context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // Set the button color to red
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(), // Add an empty container to take up the remaining space
                          ),
                          Text(
                            ' ${place.placeName}',
                            style: TextStyle(
                              height: 2,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tajawal-l",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                '${place.neighborhood} , ${place.city}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-l",
                                ),
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
        ),
      );
    } else {
      return Container();
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
            title: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(
                  "تجاربي",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Tajawal-b",
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
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
            bottom: TabBar(
              isScrollable: true,
              labelStyle: TextStyle(
                fontFamily: "Tajawal-b",
                fontWeight: FontWeight.w100,
              ),
              onTap: (index) {
                indexOfTap = index;
                setState(() {
                  switch (index) {
                    case 0:
                      selectedCategory = 'تجارب معتمدة';
                      break;
                    case 1:
                      selectedCategory = 'تجارب بانتظار الاعتماد';
                      break;
                    case 2:
                      selectedCategory = 'تجارب مرفوضة';
                      break;
                  }
                });
              },
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: 'تجارب معتمدة',
                ),
                Tab(
                  text: 'تجارب بانتظار الاعتماد',
                ),
                Tab(
                  text: 'تجارب مرفوضة',
                ),
              ],
            ),
          ),
          body: handleListItems(
            selectedCategory == 'تجارب معتمدة'
                ? accepted
                : selectedCategory == 'تجارب بانتظار الاعتماد'
                ? pending
                : selectedCategory == 'تجارب مرفوضة'
                ? rejected
                : [],
          ),
        ),
      ),
    );
  }

}

void deletePlace(placePage place) async {
  try {
    // Remove the place from Firestore
    await FirebaseFirestore.instance.collection("addedPlaces").doc(place.placeId).delete().then((_) {
      // Document successfully deleted
      showToastMessage("Deleted: ${place.placeName}");
    })
        .catchError((error) {
      // Error occurred while deleting the document
      print("Error deleting document: $error");
    });

    showToastMessage("Deleted: ${place.placeName}");
  } catch (e) {
    print("Error deleting place: $e");
  }




}

void showDeleteConfirmationDialog(placePage place, BuildContext context) {
  showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Do you want to delete this place?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              Navigator.of(context).pop(true);
              deletePlace(place);
            },
          ),
        ],
      );
    },
  ).then((result) {
    if (result != null && result) {
      deletePlace(place);
      showToastMessage("Deleted: ${place.placeName}");
    }
  });
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}

String getuser() {
  late FirebaseAuth auth = FirebaseAuth.instance;
  late User? user = auth.currentUser;
  var cpuid = user!.uid;
  return cpuid;
}