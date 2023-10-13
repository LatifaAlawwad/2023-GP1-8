import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Registration/logIn.dart';

class editUserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
    automaticallyImplyLeading: false,
    title: Center(
    child: Padding(
    padding: const EdgeInsets.only(left: 50),
    child: Text(
    "تعديل المعلومات الشخصية",
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
                  "Edit Profile Page",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Tajawal-b",
                    color: Color(0xFF6db881),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (currentUser == null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  "للاستمرار، عليك بتسجيل الدخول أولاً",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Tajawal-b",
                    color: Color(0xFF6db881),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              height: 20,
            ),
            if (currentUser == null)
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
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
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
    );
  }
}