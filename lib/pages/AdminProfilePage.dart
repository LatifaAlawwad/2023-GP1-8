import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Registration/logIn.dart';

class AdminProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
        backgroundColor: Color(0xFF6db881),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn())));
            },
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
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Tajawal-b",
                    color: Color(0xFF6db881),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // Add admin-specific content here
            // For example, you can add buttons or widgets
            // that are only available to administrators.
          ],
        ),
      ),
    );
  }
}
