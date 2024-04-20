import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Registration/SignUp.dart';
import "editProfile.dart";
import 'MyPlacesPage.dart';
import 'package:gp/Registration/logIn.dart';
import 'Calendar/TripPlanningPage.dart'; // Import the TripPlanningPage
import 'package:cloud_firestore/cloud_firestore.dart';
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

late FirebaseAuth auth = FirebaseAuth.instance;
late User? user = auth.currentUser;
late String curentId = user!.uid;

class _UserProfilePageState extends State<UserProfilePage> {
  final profileformkey = GlobalKey<FormState>();

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
            "حسابي",
            style: TextStyle(
              fontSize: 17,
              fontFamily: "Tajawal-b",
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogIn()),
              ));
            },
          ),
        ],
        toolbarHeight: 60,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Form(
                    key: profileformkey,
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: getCurrentUser(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (currentUser != null) {
                              return Column(
                                children: [
                                  SizedBox(height: 40),
                                  buildProfileOption(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => editProfile(),
                                        ),
                                      );
                                    },
                                    title: "تعديل المعلومات الشخصية",
                                    icon: Icons.edit,
                                  ),
                                  SizedBox(height: 25),
                                  buildProfileOption(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => myPlacesPage(),
                                        ),
                                      );
                                    },
                                    title: "طلبات الإضافة",
                                    icon: Icons.edit_location,
                                  ),
                                  SizedBox(height: 25),
                                  buildProfileOption(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TripPlanningPage(),
                                        ),
                                      );
                                    },
                                    title: "تخطيط الرحلات",
                                    icon: Icons.calendar_month_sharp,
                                  ),
                                ],
                              );
                            } else {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 318),
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
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileOption({required VoidCallback onPressed, required String title, required IconData icon}) {
    return Container(
      width: 350,
      height: 62,
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromARGB(119, 110, 110, 110),
          width: 1,
        ),
        color: Color.fromARGB(33, 215, 215, 218),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back if needed
            },
            icon: const Icon(Icons.keyboard_arrow_left),
            color: Colors.grey,
            iconSize: 30,
          ),
          SizedBox(width: 30),
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 109, 184, 129),
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                  Icon(
                    icon,
                    size: 20,
                    color: Color.fromARGB(255, 137, 139, 145),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future getCurrentUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? suser = auth.currentUser;
    final Uid = suser!.uid;
    final docUser = await FirebaseFirestore.instance.collection('users').doc(Uid).get();
    if (docUser.exists) {
      return SUser.fromJson(docUser.data()!); // Use fromJson here
    }
  }
}