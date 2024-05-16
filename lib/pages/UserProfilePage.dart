import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Language.dart';
import '../Registration/SignUp.dart';
import '../main.dart';
import "editProfile.dart";
import 'MyPlacesPage.dart';
import 'package:gp/Registration/logIn.dart';
import 'Calendar/TripPlanningPage.dart'; // Import the TripPlanningPage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gp/Registration/Welcome.dart';
import 'package:gp/language_constants.dart';
import 'SwitchLanguage.dart';
import 'dart:math' as math;
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
        title: Text(
          translation(context).profilePage,
          style: TextStyle(
            fontSize: 17,
            fontFamily: "Tajawal-b",
          ),
        ),
        centerTitle: true, // Center the title regardless of language directionality
        actions: [
          Directionality(
            textDirection: isArabic() ? TextDirection.rtl : TextDirection.ltr,
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                ));
              },
            ),
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
                                    title: translation(context).modifyPerInfo,
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
                                    title: translation(context).addRequest,
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
                                    title: translation(context).plans,
                                    icon: Icons.calendar_month_sharp,
                                  ),
                                  SizedBox(height: 25),
                                  buildProfileOption(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                translation(context).accountDeleteCon,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold, // Make the text bold
                                                ),
                                              ),

                                            ),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      translation(context).sureDleteAcc,
                                                      style: TextStyle(
                                                        color: Color(0xff424242),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20), // Added space between text and buttons
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // Close the dialog
                                                        },
                                                        style: TextButton.styleFrom(
                                                          primary: Color(0xff11630e),
                                                        ),
                                                        child: Text(translation(context).cancel),
                                                      ),
                                                      SizedBox(width: 20), // Added space between buttons
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // Close the confirmation dialog
                                                          _showDeleteConfirmationDialog();
                                                        },
                                                        style: TextButton.styleFrom(
                                                          primary: Color(0xff11630e),
                                                        ),
                                                        child: Text(translation(context).delete),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    title: translation(context).deleteAcc,
                                    icon: Icons.delete,
                                  ),
                                  SizedBox(height: 25),
                                  buildProfileOption(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SwitchLanguage(),
                                        ),
                                      );
                                    },
                                    title: translation(context).lang,
                                    icon: Icons.language,
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
                                        translation(context).reqLogin,
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
                                        translation(context).login,
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
  void _showDeleteConfirmationDialog() {
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translation(context).eneterInfo,
            style: TextStyle(
              fontSize: 20, // Adjust the font size as needed
            ),
            textDirection: isArabic() ? TextDirection.rtl : TextDirection.ltr,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  labelText: translation(context).email,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff11630e)), // Change color of underline without focus
                  ),
                ),
                textDirection: isArabic() ? TextDirection.rtl : TextDirection.ltr,
              ),
              TextField(
                onChanged: (value) => password = value,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: translation(context).password,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff11630e)), // Change color of underline without focus
                  ),
                ),
                textDirection: isArabic() ? TextDirection.rtl : TextDirection.ltr,
              ),
              SizedBox(height: 10), // Add some space between text fields and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the confirmation dialog
                      _deleteAccount(email, password); // Call method to delete account
                    },
                    style: TextButton.styleFrom(
                      primary: Color(0xff11630e), // Change text color
                    ),
                    child: Text(
                      translation(context).delete,
                      textDirection: isArabic() ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                  SizedBox(width: 20), // Add some space between buttons
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    style: TextButton.styleFrom(
                      primary: Color(0xff11630e), // Change text color
                    ),
                    child: Text(
                      translation(context).cancel,
                      textDirection: isArabic() ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  void _deleteAccount(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If signInWithEmailAndPassword doesn't throw an exception, the email and password are correct
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        // Account deleted successfully
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Welcome()),
        );
      } else {
        throw Exception("User is null");
      }
    } catch (e) {
      String errorMessage = '';

      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          errorMessage = translation(context).wrongPass;
        } else if (e.code == 'user-not-found') {
          errorMessage = translation(context).notRegEmail;
        } else {
          errorMessage = "${translation(context).error} ${e.code}";
        }
      } else {
        errorMessage = translation(context).errorOcurDelete;
      }

      // Show error message using Fluttertoast
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 2,
        backgroundColor: Color(0xFF6db881),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
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
        mainAxisAlignment: isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,

        children: [
          SizedBox(width: 8),
          Icon(
            icon,
            size: 20,
            color: Color.fromARGB(255, 137, 139, 145),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 109, 184, 129),
                fontFamily: "Tajawal-b",
              ),
            ),
          ),
          Spacer(), // Add a spacer to push the IconButton to the end of the row
          IconButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back if needed
            },
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.grey,
            iconSize: 20,
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