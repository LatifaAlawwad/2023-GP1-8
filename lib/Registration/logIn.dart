import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gp/pages/NavigationBarPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/language_constants.dart';

import '../pages/citiesPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final loginformkey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Form(
                    key: loginformkey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(right:Localizations.localeOf(context).languageCode == 'ar' ? 113 :0, left: 60.0), // Adjust padding as needed
                                child: Text(
                                  translation(context).login,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontFamily: "Tajawal-b",
                                    color: Color(0xFF6db881),
                                  ),
                                  textAlign: TextAlign.center, // Center the text
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0,left:20),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/welcome");
                                },
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF6db881),
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),






                        SizedBox(
                          height: 40,
                        ),
                        Image.asset(
                          "assets/images/logo.png",
                          width: 200,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: isArabic() ? Alignment.topRight : Alignment.topLeft,
                            child: TextFormField(
                              controller: email,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.mail,
                                  color: Color(0xFF6db881),
                                ),
                                labelText: translation(context).email,
                                labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                hintText: "example@gmail.com",
                                hintStyle: TextStyle(fontSize: 10),
                                fillColor: Color(0xFFdff1e0),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(66.0),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty || email.text.trim() == "") {
                                  return translation(context).reqEmail;
                                }

                                final emailPattern = RegExp(r'^[a-z0-9A-Z_.-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,3}$');

                                if (!emailPattern.hasMatch(value)) {
                                  return translation(context).correctEmail;
                                }

                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 23,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: isArabic() ? Alignment.topRight : Alignment.topLeft,
                            child: TextFormField(
                              obscureText: true,
                              controller: password,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFF6db881),
                                  size: 19,
                                ),
                                labelText: translation(context).password,
                                labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                hintText: translation(context).passConditions,
                                hintStyle: TextStyle(fontSize: 10),
                                fillColor: Color(0xFFdff1e0),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(66.0),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),

                              ),
                              validator: (value) {
                                RegExp upper = RegExp(r"(?=.*[A-Z])");
                                RegExp numb = RegExp(r"[0-9]");
                                RegExp small = RegExp(r"(?=.*[a-z])");
                                RegExp special = RegExp(r"(?=.[!@#%^&(),.?\\:{}|<>])");

                                if (value!.isEmpty || password.text.trim() == "") {
                                  return translation(context).reqPass;

                                }

                                String errorMessage = "";

                                if (value.length < 8) {
                                  errorMessage += translation(context).eightchar;
                                }

                                if (!upper.hasMatch(value)) {
                                  errorMessage += translation(context).capletter;
                                }

                                if (!small.hasMatch(value)) {
                                  errorMessage += translation(context).smaletter;
                                }

                                if (!numb.hasMatch(value)) {
                                  errorMessage += translation(context).conNum;
                                }

                                if (!special.hasMatch(value)) {
                                  errorMessage += translation(context).specialchar;
                                }

                                if (errorMessage.isNotEmpty) {
                                  errorMessage = errorMessage.trim();
                                  return errorMessage;
                                }

                                return null;
                              },

                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 40.0, left :40.0),
                          child: Align(
                            alignment: isArabic() ? Alignment.topRight : Alignment.topLeft,
                            child: Row(
                              children: [
                                Align(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/ResetPassword");
                                    },
                                    child: Text(
                                      translation(context).forgetPass,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Tajawal-b",
                                        color: Color(0xFF6db881),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              errorMessage = null; // Clear any previous error message
                            });

                            if (loginformkey.currentState!.validate()) {
                              try {
                                final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: email.text,
                                  password: password.text,
                                );

                                // Check if login is successful
                                if (userCredential.user != null) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                    return CitiesPage();
                                  }));
                                } else {
                                  // Set an error message when login fails
                                  Fluttertoast.showToast(
                                    msg: translation(context).incorrect,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                    textColor: Color.fromARGB(255, 248, 249, 250),
                                    fontSize: 18.0,
                                  );
                                }
                              } catch (e) {
                                // Handle any other exceptions that may occur during login
                                print("Error: $e");
                                Fluttertoast.showToast(
                                  msg: translation(context).network,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                  textColor: Color.fromARGB(255, 248, 249, 250),
                                  fontSize: 18.0,
                                );                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xFF6db881)),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                          ),
                          child: Text(
                            translation(context).login,
                            style: TextStyle(fontSize: 18, fontFamily: "Tajawal-m"),
                          ),
                        ),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 40.0,left:40.0),
                          child: Align(
                            alignment: isArabic() ? Alignment.topRight : Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  translation(context).noAccount,
                                  style: TextStyle(fontSize: 14, fontFamily: "Tajawal-l"),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/signup");
                                  },
                                  child: Text(
                                    translation(context).signup,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Tajawal-b",
                                      color: Color(0xFF6db881),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}