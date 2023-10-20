import 'package:flutter/material.dart';
import 'HomePage.dart';

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
          ),
          CityButton(
            cityName: 'جدة',
            imageLink: 'https://www.visitsaudi.com/content/dam/general-purpose/day-at-Jeddah.png',
          ),
        ],
      ),
    );
  }
}



class CityButton extends StatelessWidget {
  final String cityName;
  final String imageLink;

  CityButton({required this.cityName, required this.imageLink});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(cityName: cityName)),
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