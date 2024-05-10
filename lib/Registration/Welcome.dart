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
                    SizedBox(
                      height: 130,
                    ),
                    Text(
                      translation(context).title,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: "Tajawal-b",
                        color: Color(0xFF06520d),
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
                          EdgeInsets.symmetric(horizontal: 40, vertical: 9),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                      ),
                      child: Text(
                        translation(context).signup,
                        style: TextStyle(fontFamily: "Tajawal-l", fontSize: 20),
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
                          EdgeInsets.symmetric(horizontal: 35, vertical: 9),
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
                      ),
                      child: Text(
                        translation(context).login,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Tajawal-l",
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
                          EdgeInsets.symmetric(horizontal: 40, vertical: 9),
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
                      ),
                      child: Text(
                        translation(context).continueAsGuest,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Tajawal-l",
                          color: Color(0xFF06520d),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.language, color: Color(0xFF6db881)),
                      SizedBox(width: 16.0),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<Language>(
                          onChanged: (Language? language) async {
                            if(language != null){
                              Locale _locale = await setLocale(language.languageCode);
                              MyApp.setLocale(context, _locale);
                            }

                          },
                          items: Language.languageList().map<DropdownMenuItem<Language>>(
                                (e) => DropdownMenuItem<Language>(
                              value: e,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    e.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
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
  }
}