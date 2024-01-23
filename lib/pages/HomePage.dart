import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'FilterPage.dart';
import 'citiesPage.dart';
import 'placePage.dart';
import 'placeDetailsPage.dart';
import 'AddPage.dart';
import 'neighbourhood.dart';


class HomePage extends StatefulWidget {
  final String cityName;

  HomePage({required this.cityName, required int cityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $cityName'),
      ),
      body: Center(
        child: Text('Details for $cityName go here.'),
      ),
    );
  }
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int indexOfTap = 0;
  List<placePage> allData = [];
  List<placePage> attractions = [];
  List<placePage> restaurants = [];
  List<placePage> malls = [];
 static bool isDownloadedData = false;
  String name = '';
  String selectedCategory = 'الكل';

  List<placePage> searchResults = [];


  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('ApprovedPlaces').get();
      if (snapshot.docs.isNotEmpty) {
        allData.clear();
        attractions.clear();
        restaurants.clear();
        malls.clear();

        snapshot.docs.forEach((element) {
          final category = element.data()["category"];

          placePage place = placePage.fromMap(element.data());

          if (category == "فعاليات و ترفيه") {
            attractions.add(place);
          } else if (category == "مطاعم") {
            restaurants.add(place);
          } else if (category == "مراكز تسوق") {
            malls.add(place);
          }

          allData.add(place);
        });

        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Inside your `handleListItems` method

  Widget handleListItems(List<placePage> listItem) {
    if (listItem.isEmpty) {
      return Center(
        child: Text(
          "لم يتم العثور على نتائج",
          style: TextStyle(
            color: Color(0xFF6db881), // Set your desired color
            fontSize: 16,
          ),
        ),
      );
    } else {
      return ListView.separated(
        itemCount: listItem.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 10);
        },
        itemBuilder: (BuildContext context, int index) {
          if (listItem[index] is placePage) {
            final place = listItem[index] as placePage;

            // Filter places based on the selected city (الرياض or جدة)
            if (place.city == widget.cityName) {
              return _buildItem(
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => placeDetailsPage(place: listItem[index]),
                    ),
                  );
                },
                place,
                context,
              );
            }
          }
          return Container();
        },
      );
    }
  }


  Widget _buildItem(void Function()? onTap, placePage place, BuildContext context) {
    if (selectedCategory == 'الكل' || place.category == selectedCategory) {
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
                            '${place.placeName}',
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
                        //mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child:Row(
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
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      List<double> ratings = List<double>.from(
                                        snapshot.data!.docs.map((doc) {
                                          final commentData = doc.data() as Map<String, dynamic>;
                                          return commentData["rating"].toDouble() ?? 0.0;
                                        }),
                                      );

                                      // Calculate the average rating
                                      double averageRating =
                                      ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;

                                      return Row(
                                        children: [
                                          for (int index = 0; index < 5; index++)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                              child: Icon(
                                                index < averageRating.floor()
                                                    ? Icons.star
                                                    : index + 0.5 == averageRating
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                                color: const Color.fromARGB(255, 109, 184, 129),
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
                          // SizedBox(width: 10),
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
  void performSearch(String query) {
    searchResults.clear();

    if (query.isEmpty) {
      setState(() {
        name = '';
      });
    } else {
      final formattedQuery = query.replaceAll(' ', '').toLowerCase();
      searchResults = allData.where((place) {
        final formattedName = place.placeName.replaceAll(' ', '').toLowerCase();
        return formattedName.contains(formattedQuery);
      }).toList();

      // Sort the search results based on the order of letters.
      searchResults.sort((a, b) {
        final formattedA = a.placeName.replaceAll(' ', '').toLowerCase();
        final formattedB = b.placeName.replaceAll(' ', '').toLowerCase();
        return formattedA.indexOf(formattedQuery) - formattedB.indexOf(formattedQuery);
      });

      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Color(0xFF6db881),
                    title: Row(
                      children: [

                        Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FilterPage()),
                              );
                            },
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),

                        Expanded(

                          child: TextField(
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                              performSearch(value);
                            },


                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(
                                    255, 17, 99, 14)),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              alignLabelWithHint: true,
                              hintText: 'ابحث عن مطعم أو مكان سياحي',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(143, 255, 255, 255),
                                fontFamily: "Tajawal-m",
                              ),
                            ),
                            cursorColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    actions: [

                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CitiesPage()),
                            );
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
                      ),
                      labelPadding: EdgeInsets.symmetric(horizontal: 1.0),
                      onTap: (index) {
                        indexOfTap = index;
                        setState(() {
                          switch (index) {
                            case 0:
                              selectedCategory = 'الكل';
                              break;
                            case 1:
                              selectedCategory = 'فعاليات و ترفيه';
                              break;
                            case 2:
                              selectedCategory = 'مطاعم';
                              break;
                            case 3:
                              selectedCategory = 'مراكز تسوق';
                              break;
                          }
                        });
                      },
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(
                          text: 'الكل',
                        ),
                        Tab(
                          text: 'فعاليات و ترفيه',
                        ),
                        Tab(
                          text: 'مطاعم',
                        ),
                        Tab(
                          text: 'مراكز تسوق',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(

                  child: handleListItems(
                    name.isEmpty
                        ? selectedCategory == 'فعاليات و ترفيه'
                        ? attractions
                        : selectedCategory == 'مطاعم'
                        ? restaurants
                        : selectedCategory == 'مراكز تسوق'
                        ? malls
                        : allData
                        : searchResults,
                  ),
                ),
              ],
            ),
            ),
        );
    }
}