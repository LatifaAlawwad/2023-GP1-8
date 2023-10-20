import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Registration/logIn.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 109, 184, 129),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 155),
            child: Text(
              "المفضلة",
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Tajawal-b",
              ),
            ),
          ),
        toolbarHeight: 60,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            if (currentUser != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  "FavoritePage",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Tajawal-b",
                    color: Color(0xFF6db881),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (currentUser == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 79),
                      child: Text(
                        "عذراً لابد من تسجيل الدخول",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Tajawal-b",
                          color: Color(0xFF6db881),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogIn()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xFF6db881)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                      ),
                      child: Text(
                        "تسجيل الدخول",
                        style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}