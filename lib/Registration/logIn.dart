import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/pages/NavigationBarPage.dart';


import '../pages/citiesPage.dart';


class LogIn extends StatefulWidget {
  const LogIn({Key? key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final loginformkey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "تسجيل الدخول ",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontFamily: "Tajawal-b",
                                  color: Color(0xFF6db881),
                                ),
                              ),
                              SizedBox(
                                width: 70,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
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
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              controller: email,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.mail,
                                  color: Color(0xFF6db881),
                                ),
                                labelText: "البريد الإلكتروني:",
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
                                  return "البريد الإلكتروني مطلوب";
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 23,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
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
                                labelText: "كلمة المرور:",
                                labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                hintText: "أدخل كلمة مرور صالحة",
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
                                if (value!.isEmpty || password.text.trim() == "") {
                                  return "كلمة السر مطلوبة";
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/RessetPassword");
                                },
                                child: Text(
                                  "نسيت كلمة المرور؟",
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
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (loginformkey.currentState!.validate()) {
                              try {
                                final userCredential = await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: email.text,
                                  password: password.text,
                                );

                                // Check if login is successful
                                if (userCredential.user != null) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                    return CitiesPage();
                                  }));
                                } else {
                                  // Handle the case where userCredential.user is null (login failed)
                                  Fluttertoast.showToast(
                                    msg: "البريد الإلكتروني أو كلمة المرور غير صحيحة",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Color(0xFF6db881),
                                    textColor: Color(0xFFF8F9FA),
                                    fontSize: 18.0,
                                  );
                                }
                              } catch (e) {
                                // Handle any other exceptions that may occur during login
                                print("Error: $e");
                                // You can add more specific error handling here if needed
                              }
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
                            "تسجيل الدخول",
                            style: TextStyle(fontSize: 18, fontFamily: "Tajawal-m"),
                          ),
                        ),

                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/signup");
                                },
                                child: Text(
                                  "إنشاء حساب   ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Tajawal-b",
                                    color: Color(0xFF6db881),
                                  ),
                                ),
                              ),
                              Text(
                                " ليس لديك حساب؟",
                                style: TextStyle(fontSize: 14, fontFamily: "Tajawal-l"),
                              ),
                            ],
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
