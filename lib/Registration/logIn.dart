import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gp/Registration/Welcome.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Function to handle user sign-in
  Future<void> signIn() async {
    if (loginFormKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );

        // Check if the user is an admin or a standard user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((documentSnapshot) {
          if (documentSnapshot.exists) {
            bool isAdmin = documentSnapshot['isAdmin'];
            if (isAdmin) {
              // Handle admin login
            } else {
              // Handle standard user login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Welcome(),
                ),
              );
            }
          }
        });
      } catch (e) {
        print("Error during sign-in: $e");
        Fluttertoast.showToast(
          msg: "البريد الإلكتروني أو كلمة المرور غير صحيحة",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Color(0xFF6db881),
          textColor: Color(0xFFfcfdff),
          fontSize: 18.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Form(
                  key: loginFormKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "تسجيل الدخول ",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: "Tajawal-b",
                              color: Color(0xFF6db881),
                            ),
                          ),
                          SizedBox(
                            width: 45,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Welcome(),
                                  ),
                                );
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
                              labelText: " البريد الإلكتروني :",
                              labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                              hintText: "example@gmail.com",
                              hintStyle: TextStyle(fontSize: 10),
                              fillColor: Color(0xFFe1f3e3),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(66.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty || email.text.trim() == "") {
                                return "البريد الإلكتروني مطلوب ";
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
                              hintText: "أدخل كلمة مرور صالحة ",
                              hintStyle: TextStyle(fontSize: 10),
                              fillColor: Color(0xFFe1f3e3),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(66.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty || password.text.trim() == "") {
                                return "كلمة السر مطلوبة ";
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/forgetPassword");
                            },
                            child: Text(
                              "نسيت كلمة المرور ؟        ",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Tajawal-b",
                                color: Color(0xFF6db881),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        onPressed: signIn,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF6db881),
                          ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/signup");
                            },
                            child: Text(
                              "إنشاء حساب ",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Tajawal-b",
                                color: Color(0xFF6db881),
                              ),
                            ),
                          ),
                          Text(
                            " ليس لديك حساب ؟     ",
                            style: TextStyle(fontSize: 14, fontFamily: "Tajawal-l"),
                          ),
                        ],
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
