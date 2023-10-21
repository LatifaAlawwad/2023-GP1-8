// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

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
                        "!اهلاً بك في سهيل",
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
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF6db881)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 9)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27))),
                        ),
                        child: Text(
                          "انشاء حساب",
                          style:
                          TextStyle(fontFamily: "Tajawal-l", fontSize: 20),
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
                              EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 9)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27))),
                          side: MaterialStateProperty.all(BorderSide(
                              color: Color(0xFFc5e8c7),
                              width: 1.0,
                              style: BorderStyle.solid)),
                        ),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Tajawal-l",
                              color: Color(0xFF06520d)),
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
                                EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 9)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27))),
                            side: MaterialStateProperty.all(BorderSide(
                                color:Color(0xFFc5e8c7),
                                width: 1.0,
                                style: BorderStyle.solid))),
                        child: Text(
                          "المتابعة كزائر",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Tajawal-l",
                              color: Color(0xFF06520d)),
                        ),
                      ),
                    ],
                  )),
              /* Positioned(
                  left: 10,
                  bottom: 0,
                  child: Image.asset(
                    "assets/images/House_searching.png",
                    width: 375,
                  ))*/
            ],
          ),
        ),
      ),
    );
  }
}