import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'NavigationBarPage.dart';
import 'package:gp/language_constants.dart';

class CitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              translation(context).selectCity,
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Tajawal-b",
              ),
            ),
            SizedBox(width: 40), // Adjust the width based on your preference
          ],
        ),
        centerTitle: false,

      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CityButton(
              cityName: translation(context).riyadh,
              imageLink: 'https://omrania.com/wp-content/uploads/Kingdom-Centre-Riyadh-KSA-Bin-Mahdi-cover.jpg',
              cityId: 3,
            ),
            CityButton(
              cityName: translation(context).jeddah,
              imageLink: 'https://preview.redd.it/ckmkqajqdf161.jpg?auto=webp&s=441bbb3504fb1dd698371b74b1b1e8033bdec3ec',
              cityId: 18,
            ),
            CityButton(
              cityName: translation(context).abha,
              imageLink: 'https://sa.aqar.fm/blog/wp-content/uploads/2023/02/%D8%B1%D8%AC%D8%A7%D9%84-%D8%A3%D9%84%D9%85%D8%B9-950x500.jpg',
              cityId: 15,
            ),
            CityButton(
              cityName: translation(context).alula,
              imageLink: 'https://www.vision2030.gov.sa/media/mtukxauc/elephant-rock.jpg?width=1920&format=webp',
              cityId: 13,
            ),

            CityButton(
              cityName: translation(context).east,
              imageLink: 'https://welcomesaudi.com/uploads/0000/1/2021/07/23/85-dammam-corniche-eastern-province-900.jpg',
              cityId: 3,
            ),
          ],
        ),
      ),
    );
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
              // Determine which city was selected and pass it to NavigationBarPage.
              String selectedCity = cityName;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return NavigationBarPage(selectedCity: selectedCity);
                  },
                ),
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
                        right: isArabic()? 0:20,
                        left: isArabic()? 0:20,

                        child: Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 25,
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
}//https://pbs.twimg.com/media/EYbBNxuWAAAehiN.jpg
