import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'NavigationBarPage.dart';

class citiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 109, 184, 129),
          automaticallyImplyLeading: false,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                "مدن السعودية",
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

        ),
    body: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

    CityButton(
    cityName: 'الرياض',
    imageLink: 'https://content.r9cdn.net/rimg/dimg/7d/60/488863c5-city-35744-16935f1b104.jpg',
    cityId: 3,
    ),
    CityButton(
    cityName: 'جدة',
    imageLink: 'https://www.visitsaudi.com/content/dam/general-purpose/day-at-Jeddah.png',
    cityId: 18,
    ),
    ],
    ));
  }
}



class CityButton extends StatelessWidget {
  final String cityName;
  final String imageLink;
  final int cityId;

  CityButton({required this.cityName, required this.imageLink, required this.cityId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return const NavigationBarPage(); // Navigate to NavigationBarPage
                }),
              );
            },
            child: Container(
              width: 400, // Set the width to the desired size
              height: 200, // Set the height to the desired size
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Set border radius here
                ),
                elevation: 8, // Increase the elevation for a stronger shadow effect
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Match the border radius
                  child: Stack(
                    children: [
                      Image.network(
                        imageLink,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 23,
                            fontFamily: "Tajawal-b",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}


