import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'NavigationBarPage.dart';
import '../Registration/logIn.dart';
import 'placePage.dart';
import 'placeDetailesPage.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static int indexOfTap = 0;
  static List<dynamic> allData = [];
  static List<dynamic> attractions = [];
  static List<dynamic> restaurants = [];
  static List<dynamic> malls = [];

  static List<dynamic> searchItems = [];
  static List<dynamic> searchAttractions = [];
  static List<dynamic> searchRestaurants = [];
  static List<dynamic> searchMalls = [];
  static bool isDownloadedData = false;

  static String name = '';
  static String? placeId;
  static String? placeName;
  static String? userId;
  static String? category;
  static String? placeCity;
  static String? placeNeighborhood;
  static List<String>? images;
  static String? description;
  static String? Location;




  void _handleData(QuerySnapshot<Map<String, dynamic>> data) async {
    try {
      allData.clear();
      attractions.clear();
      restaurants.clear();
      malls.clear();
      data.docs.forEach((element) {
        if (element.data()["category"] == "Attraction") {
          placePage attraction = placePage.fromMap(element.data());
          allData.add(attraction);
         // handleRentAndSaleItems(attraction);
        }

        if (element.data()["category"] == "Restaurants") {
          placePage restaurants = placePage.fromMap(element.data());
          allData.add(restaurants);
          //handleRentAndSaleItems(restaurants);

        }

        if (element.data()["category"] == "Mall") {
          placePage mall = placePage.fromMap(element.data());
          allData.add(mall);
         // handleRentAndSaleItems(mall);

        }


      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {});
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Widget handleListItems(List<dynamic> listItem) {

    return ListView.separated(
      itemCount: listItem.length,
      separatorBuilder: (BuildContext context, int index) { //defines the appearance of the separators between the items
        return SizedBox(height: 10);
      },
      itemBuilder: (BuildContext context, int index) {
        if (listItem[index] is placePage) {
          return _buildItem(
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => placeDetailesPage(place: listItem[index] as placePage)),
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

  Widget _handleSnapshot(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Text("حصل خطأً ما");
    }
    if (!snapshot.hasData) {
      return Text("لا توجد بيانات");
    }
    if (snapshot.hasData) {
      if (allData.isEmpty || !isDownloadedData) {
        isDownloadedData = true;
        _handleData(snapshot.data!);
      }
      return handleListItems(allData);
    }
    return Container();
  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: AppBar(
                backgroundColor: Color.fromARGB(255, 127, 166, 233),
                title: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 14, 41, 99)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          alignLabelWithHint: true,
                          hintText: 'البحث',
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
                ],
                bottom: TabBar(
                  labelStyle: TextStyle(
                    fontFamily: "Tajawal-b",
                    fontWeight: FontWeight.w100,
                  ),
                  onTap: (index) {
                    print("Index of tap is: $index");
                    indexOfTap = index;
                  },
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      text: 'الكل',
                    ),
                    Tab(
                      text: 'أماكن سياحية',
                    ),
                    Tab(
                      text: 'مطاعم',
                    ),
                    Tab(
                      text: 'مراكز التسوق',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
               //   name.isEmpty ? _buildItem() : _buildSearchItems(),
                  name.isEmpty ? handleListItems(attractions) : handleListItems(searchAttractions),
                  name.isEmpty ? handleListItems(restaurants) : handleListItems(searchRestaurants),
                  name.isEmpty ? handleListItems(malls) : handleListItems(searchMalls)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}












Widget _buildItem(void Function()? onTap,placePage place, BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          )),
      child: Container(
        height: 210,
        decoration: '${place.images.length}' == '0'
            ? BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'),
              fit: BoxFit.cover),
        )
            : BoxDecoration(
          image: DecorationImage(
              image: NetworkImage('${place.images[0]}'), fit: BoxFit.cover),
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
                      Text(
                        ' ${place.placeName}',
                        style: TextStyle(
                          height: 2,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Tajawal-l",
                        ),
                      )

                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                        ],
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
}
