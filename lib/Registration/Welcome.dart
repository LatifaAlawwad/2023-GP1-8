import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gp/language_constants.dart';
import 'package:gp/main.dart';

import '../Language.dart';


class Welcome extends StatefulWidget {


  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [

                    Padding(
                      padding: EdgeInsets.only(top:150.0), // Add padding of 8.0 pixels only to the top
                      child: Text(
                        translation(context).title,
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: "Tajawal-b",
                          color: Color(0xFF06520d),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      "assets/images/logo.png",
                      width: 200,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Color(0xFF6db881)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(Size(180, 45)),                       ),

                      child: Text(
                        translation(context).signup,
                        style: TextStyle(fontFamily: "Tajawal-l",fontWeight: Localizations.localeOf(context).languageCode == 'ar'
                            ?FontWeight.w600 // For Arabic text, use normal weight
                            : FontWeight.w900, fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 255, 255, 255)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Color(0xFFc5e8c7),
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(Size(180, 45)),                       ),


                      child: Text(
                        translation(context).login,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Tajawal-l",fontWeight: Localizations.localeOf(context).languageCode == 'ar'
                            ?  FontWeight.w600
                            : FontWeight.w900,
                          color: Color(0xFF06520d),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/citiesPage");
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 255, 255, 255)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Color(0xFFc5e8c7),
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(Size(180, 45)),                       ),
                      child: Text(
                        translation(context).continueAsGuest,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Tajawal-l",fontWeight: Localizations.localeOf(context).languageCode == 'ar'
                            ? FontWeight.w600
                            : FontWeight.w900,
                          color: Color(0xFF06520d),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Localizations.localeOf(context).languageCode == 'ar' ? Alignment.topRight: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: PopupMenuButton<Language>(
                      icon: Transform.scale(
                        scale: 1.2, // Adjust the scale factor as needed
                        child: Icon(Icons.language, color: Color(0xFF6db881)),
                      ),
                      itemBuilder: (BuildContext context) {
                        return Language.languageList().map((Language e) {
                          return PopupMenuItem<Language>(
                            value: e,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  e.flag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Text(
                                  e.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (Language? language) async {
                        if (language != null) {
                          Locale _locale = await setLocale(language.languageCode);
                          MyApp.setLocale(context, _locale);
                        }
                      },
                    ),
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