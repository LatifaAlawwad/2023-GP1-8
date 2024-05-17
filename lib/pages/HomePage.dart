import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'FilterPage.dart';
import 'cities.dart';
import 'citiesPage.dart';
import 'neighbourhood.dart';
import 'placePage.dart';
import 'placeDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gp/language_constants.dart';

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
  bool showRecommendations = true;
  static bool FilterValue = false;
  static String noResults = "";

  static List<placePage> FilteredItems = [];
  static List<placePage> FilterForAtt = [];
  static List<placePage> FilterForRes = [];
  static List<placePage> FilterForMall = [];
  Map<String, dynamic>? filters;
  String url = '';
  var data;

  int indexOfTap = 0;
  static List<dynamic> allData = [];
  List<placePage> attractions = [];
  List<placePage> restaurants = [];
  List<placePage> malls = [];
  static bool isDownloadedData = false;
  String name = '';
  String selectedCategory = 'الكل';

  static List<dynamic> searchResults = [];

  String? userId;
  List<dynamic> recommendations = [];
  List<dynamic> output = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
    fetchUserId();
  }

  Future<void> fetchUserId() async {
    // Retrieve user ID using FirebaseAuth
    userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Fetch recommendations if user ID is available
      await fetchRecommendations();
    } else {
      // Handle when user ID is not available
      print('User ID not found');
    }
  }

  Future<void> fetchRecommendations() async {
    String cityName = widget.cityName;

    try {
      if (userId == null) {
        print('User ID is null.');
        return;
      }

      var url =
          'https://arcane-everglades-69652-26a0add2c8af.herokuapp.com/api?user_id=$userId&city_name=$cityName';
      print('Fetching recommendations for user ID: $userId');
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseBody = response.body;
        print('Response body: $responseBody');

        var parsedResponse = jsonDecode(responseBody);

        if (parsedResponse['api'] == null) {
          print('Recommendations are null.');
          return;
        }
        bool showRecommendations = true;
        List<dynamic> recommendations = parsedResponse['api'];

        // Extracting place_id and storing it in the output list
        output =
            List<String>.from(recommendations.map((item) => item['place_id']));
        print('Place IDs: $output');

        // Update state here if necessary
        setState(() {
          recommendations = recommendations;
        });
      } else {
        // Handle error
        print('Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Error fetching recommendations: $e');
    }
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
  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('ApprovedPlaces').get();
      if (snapshot.docs.isNotEmpty) {
        allData.clear();
        attractions.clear();
        restaurants.clear();
        malls.clear();
        FilterForMall.clear();
        FilterForAtt.clear();
        FilterForRes.clear();

        snapshot.docs.forEach((element) {
          final category = element.data()["category"];

          placePage place = placePage.fromMap(element.data());

          if (category == "فعاليات و ترفيه") {
            attractions.add(place);
            FilterForAtt.add(place);
          } else if (category == "مطاعم") {
            restaurants.add(place);
            FilterForRes.add(place);
          } else if (category == "مراكز تسوق") {
            malls.add(place);
            FilterForMall.add(place);
          }

          allData.add(place);
        });

        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget handleListItems(
      List<placePage> listItem, Map<String, dynamic>? filters) {
    List<Widget> filteredItems = [];

    for (int index = 0; index < listItem.length; index++) {
      if (listItem[index] is placePage) {
        final place = listItem[index] as placePage;

        if (place.city == widget.cityName) {
          if (filters != null && FilterValue == true) {
            if (filters["type"] == 1) {
              if (place.category == 'فعاليات و ترفيه' &&
                  (filters["typeEntNames"].isEmpty ||
                      filters["typeEntNames"].contains(place.typeEnt)) &&
                  (filters["INorOUT"] == '' ||
                      filters["INorOUT"] == null ||
                      place.INorOUT == filters["INorOUT"]) &&
                  (filters["hasReservation"] == null ||
                      place.hasReservation == filters["hasReservation"])) {
                filteredItems.add(_buildItem(
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            placeDetailsPage(place: listItem[index]),
                      ),
                    );
                  },
                  place,
                  context,
                ));
              }
            } else if (filters["type"] == 2) {
              if (place.category == 'مطاعم' &&
                  (filters["cusNames"].isEmpty ||
                      filters["cusNames"]
                          .any((name) => place.cuisine.contains(name))) &&
                  (filters["price"].isEmpty ||
                      filters["price"].contains(place.priceRange)) &&
                  (filters["serves"].isEmpty ||
                      filters["serves"]
                          .any((value) => place.serves.contains(value))) &&
                  (filters["atmosphere"].isEmpty ||
                      filters["atmosphere"]
                          .any((value) => place.atmosphere.contains(value))) &&
                  (filters["hasReservation"] == null ||
                      place.hasReservation == filters["hasReservation"])) {
                filteredItems.add(_buildItem(
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            placeDetailsPage(place: listItem[index]),
                      ),
                    );
                  },
                  place,
                  context,
                ));
              }
            } else if (filters["type"] == 3) {
              Set<String> InMalls = Set<String>();
              if (place.hasCinema) InMalls.add('سينما');
              if (place.hasFoodCourt) InMalls.add('منطقة مطاعم');
              if (place.hasPlayArea) InMalls.add('منطقة ألعاب');
              if (place.hasSupermarket) InMalls.add('سوبرماركت');

              if (place.category == 'مراكز تسوق' &&
                  (filters["typeEntInMallsNames"].isEmpty ||
                      filters["typeEntInMallsNames"]
                          .any((name) => InMalls.contains(name))) &&
                  (filters["INorOUT"] == '' ||
                      filters["INorOUT"] == null ||
                      place.INorOUT == filters["INorOUT"]) &&
                  (filters["shopType"].isEmpty ||
                      filters["shopType"].any(
                          (shoptype) => place.shopType.contains(shoptype)))) {
                filteredItems.add(_buildItem(
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            placeDetailsPage(place: listItem[index]),
                      ),
                    );
                  },
                  place,
                  context,
                ));
              }
            }
          } else {
            filteredItems.add(_buildItem(
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        placeDetailsPage(place: listItem[index]),
                  ),
                );
              },
              place,
              context,
            ));
          }
        }
      }
    }


    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          translation(context).noResults,
          style: TextStyle(
            color: Color(0xFF6db881),
            fontSize: 16,
          ),
        ),
      );
    } else {
      return ListView.separated(
        itemCount: filteredItems.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 0);
        },
        itemBuilder: (BuildContext context, int index) {
          return filteredItems[index];
        },
      );
    }
  }

  bool checkFilterNoResults(Map<String, dynamic>? filters) {
    if (FilterValue == false) {
      return false;
    }

    if (filters != null) {
      if (filters["type"] == 1 &&
          (selectedCategory == 'مطاعم' || selectedCategory == 'مراكز تسوق')) {
        return true;
      } else if (filters["type"] == 2 &&
          (selectedCategory == 'فعاليات و ترفيه' ||
              selectedCategory == 'مراكز تسوق')) {
        return true;
      } else if (filters["type"] == 3 &&
          (selectedCategory == 'فعاليات و ترفيه' ||
              selectedCategory == 'مطاعم')) {
        return true;
      }
    }
    return false;
  }

  Widget _buildPlacePageWidget2(BuildContext context, placePage place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => placeDetailsPage(place: place),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              //spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              image: place.images.isEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                        'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg',
                      ),
                      fit: BoxFit.fill,
                    )
                  : DecorationImage(
                      image: NetworkImage(place.images[0]),
                      fit: BoxFit.fill,
                    ),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                boxShadow: [],
              ),
              child: Column(
                crossAxisAlignment:isArabic()? CrossAxisAlignment.end:
                    CrossAxisAlignment.start, // Align text to the right
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Align(
                    alignment:Localizations.localeOf(context).languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft, // Align text to the right
                    child: Text(
                      '${place.placeName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Tajawal-l",
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Align(
                    alignment: isArabic()?Alignment.centerRight :Alignment.centerLeft, // Align text to the right
                    child: Row(
                      mainAxisAlignment: isArabic()?MainAxisAlignment.end:MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'?'${place.neighbourhood} ، ${place.city}' :' ${getNeighbourhoodEnName(place.neighbourhood)}, ${getCityEnName(place.city)} ',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-l",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  Align(
                    alignment: isArabic()?Alignment.centerRight :Alignment.centerLeft, // Align text to the right
                    child: Row(
                      mainAxisAlignment: isArabic()?MainAxisAlignment.end:MainAxisAlignment.start,
                      children: [
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
                                final commentData =
                                    doc.data() as Map<String, dynamic>;
                                return commentData["rating"].toDouble() ?? 0.0;
                              }),
                            );

                            double averageRating = ratings.isNotEmpty
                                ? ratings.reduce((a, b) => a + b) /
                                    ratings.length
                                : 0.0;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget _buildItem(
      void Function()? onTap,
      placePage place,
      BuildContext context,
      ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (selectedCategory == 'الكل' || place.category == selectedCategory) {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            height: 210,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: place.images.isNotEmpty
                        ? Image.network(
                      place.images[0],
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
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
                          mainAxisAlignment: isArabic
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
                                    final commentData =
                                    doc.data() as Map<String, dynamic>;
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
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }



/////////////////////////////////////////////////////////////////////////////////////////////////////
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
        return formattedA.indexOf(formattedQuery) -
            formattedB.indexOf(formattedQuery);
      });

      setState(() {});
    }
  }

  ScrollController _scrollController = ScrollController();
/////////////////////////////////////////////////////////////////////////////////////
  ///@override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Color(0xFF6db881),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Color(0xFF6db881),
                title: Row(
                  mainAxisAlignment: isArabic() ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CitiesPage(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                          performSearch(value);
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
                        cursorColor: Colors.white,
                      ),
                    ),

                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilterPage(),
                          ),
                        );
                        setState(() {
                          if (result != null && result is Map<String, dynamic>) {
                            FilterValue = true;
                            filters = result;

                            dynamic filtertype = result["type"];
                            if (filtertype == 1) {
                              FilteredItems = FilterForAtt;
                            } else if (filtertype == 2) {
                              FilteredItems = FilterForRes;
                            } else if (filtertype == 3) {
                              FilteredItems = FilterForMall;
                            }
                          } else if (result == null) {
                            FilterValue = false;
                          }
                        });
                      },
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ],
                ),
                toolbarHeight: 60,
              ),

            ),
            Container(
              child: Visibility(
                visible: searchResults.isEmpty && FilterValue == false,
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: output.map((placeId) {
                            for (int i = 0;
                            i < HomePageState.allData.length;
                            i++) {
                              if (HomePageState.allData[i] is placePage) {
                                placePage place =
                                HomePageState.allData[i] as placePage;
                                if (place.place_id == placeId) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: 30.0, left: 8.0, right: 8.0),
                                    child: SizedBox(
                                      height: 150.0,

                                      child: _buildPlacePageWidget2(context, place),
                                    ),
                                  );
                                }
                              }
                            }
                            return Container();
                          }).toList(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              translation(context).like,
                              style: TextStyle(
                                fontFamily: "Tajawal-m",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                labelStyle: TextStyle(
                  fontFamily: "Tajawal-b",
                  fontWeight: FontWeight.w100,
                  color: Color(0xFF6db881),
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
                indicatorColor: Color(0xFF6db881),
                tabs: [

                  Tab(
                    child: Text(
                      translation(context).all,
                      style: TextStyle(
                        color: Color(0xFF6db881), // Set the text color to match the labelStyle
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      translation(context).ent,
                      style: TextStyle(
                        color: Color(0xFF6db881), // Set the text color to match the labelStyle
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      translation(context).rest,
                      style: TextStyle(
                        color: Color(0xFF6db881), // Set the text color to match the labelStyle
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      translation(context).mall,
                      style: TextStyle(
                        color: Color(0xFF6db881), // Set the text color to match the labelStyle
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: handleListItems(
                name.isEmpty && FilterValue == false
                    ? selectedCategory == 'فعاليات و ترفيه'
                    ? attractions
                    : selectedCategory == 'مطاعم'
                    ? restaurants
                    : selectedCategory == 'مراكز تسوق'
                    ? malls
                    : allData.cast<placePage>()
                    : name.isEmpty && FilterValue == true
                    ? selectedCategory == 'فعاليات و ترفيه'
                    ? FilterForAtt
                    : selectedCategory == 'مطاعم'
                    ? FilterForRes
                    : selectedCategory == 'مراكز تسوق'
                    ? FilterForMall
                    : FilteredItems
                    : searchResults.cast<placePage>(),
                filters,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
