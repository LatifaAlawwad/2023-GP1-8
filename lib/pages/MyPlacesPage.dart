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
  String selectedCategory = 'طلبات معتمدة';

  List<placePage> searchResults = [];

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
                  "طلبات الإضافة",
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
                  text: 'طلبات معتمدة',
                ),
                Tab(
                  text: 'طلبات بانتظار الاعتماد',
                ),
                Tab(
                  text: 'طلبات مرفوضة',
                ),
              ],
            ),
          ),
          body: handleListItems(
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
        "لم يتم العثور على نتائج",
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
    if (selectedCategory == 'طلبات معتمدة' ||
        selectedCategory == 'طلبات بانتظار الاعتماد' ||
        selectedCategory == 'طلبات مرفوضة') {
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${place.neighbourhood} , ${place.city}',
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
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    showDeleteConfirmationDialog(place, selectedCategory);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
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
        return AlertDialog(
          title: Text("تأكيد الحذف"),
         content: Text("هل تريد حذف المكان التالي؟\n\nkk: ${place.placeName}"),
          actions: <Widget>[
            TextButton(
              child: Text("إلغاء"),
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("حذف"),
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).pop(true);
                deletePlace(place.place_id, selectedCategory);
              },
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result) {
        deletePlace(place.place_id, selectedCategory);
      }
    });
    }

    Future<void> deletePlace(String place_id, String selectedCategory) async {
      try {
        switch (selectedCategory) {
          case 'طلبات معتمدة':
            await FirebaseFirestore.instance.collection("ApprovedPlaces").doc(place_id).delete();
            setState(() {
              accepted.removeWhere((place) => place.place_id == place_id);
            });
            break;
          case 'طلبات بانتظار الاعتماد':
            await FirebaseFirestore.instance.collection("PendingPlaces").doc(place_id).delete();
            setState(() {
              pending.removeWhere((place) => place.place_id == place_id);
            });
            break;
          case 'طلبات مرفوضة':
            await FirebaseFirestore.instance.collection("RejectedPlaces").doc(place_id).delete();
            setState(() {
              rejected.removeWhere((place) => place.place_id == place_id);
            });
            break;
        }

      print("Deleted place_id: $place_id from collection: $selectedCategory");
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
