import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'NavigationBarPage.dart';

class citiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Color(0xFF6db881),
    title: const Padding(
    padding: EdgeInsets.only(left: 150),
    child: Text(
    "اختر المدينة",
    style: TextStyle(
    fontSize: 20,
    fontFamily: "Tajawal-b",
    color: Colors.white,
    ),
    ),
    ),
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
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return const NavigationBarPage(); // Navigate to NavigationBarPage
          }),
        );

      },
      child: Padding(
        padding: const EdgeInsets.only(top: 1, bottom: 60),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          elevation: 4,
          child: Stack(
            children: [
              Container(
                height: 190,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageLink),
                    fit: BoxFit.cover,
                  ),
                ),
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
    );
  }
}