// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/Registration/Welcome.dart';
import 'package:gp/pages/NavigationBarPage.dart';

import '../pages/citiesPage.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final signformkey = GlobalKey<FormState>();
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
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
                    key: signformkey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "إنشاء حساب",
                              style: TextStyle(
                                  fontSize: 26,
                                  fontFamily: "Tajawal-b",
                                  color: Color(0xFF6db881)),
                            ),
                            SizedBox(
                              width: 80,
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Welcome()),
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
                          height: 8,
                        ),
                        Image.asset(
                          "assets/images/logo.png",
                          width: 200,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextFormField(
                                controller: _usernameController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Color(0xFF6db881),
                                  ),
                                  labelText: "  الأسم  :",
                                  labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                  fillColor: Color(0xFFdff1e0),
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(66.0),
                                      borderSide:
                                      const BorderSide(width: 0, style: BorderStyle.none)),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty || _usernameController.text.trim() == "") {
                                    return "الأسم مطلوب ";
                                  }
                                  if (RegExp(r'[0-9]').hasMatch(value)) {
                                    return 'الرجاء إدخال أحرف فقط';
                                  }
                                },
                              ),
                            )),
                        SizedBox(
                          height: 23,
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextFormField(
                                controller: _emailController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mail,
                                    color: Color(0xFF6db881),
                                  ),
                                  labelText: " البريد الإلكتروني :",
                                  labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                  hintText: "exampel@gmail.com",
                                  hintStyle: TextStyle(fontSize: 10),
                                  fillColor: Color(0xFFdff1e0),
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(66.0),
                                      borderSide:
                                      const BorderSide(width: 0, style: BorderStyle.none)),
                                ),
                                  validator: (value) {
                                    if (value!.isEmpty || _emailController.text.trim() == "") {
                                      return "البريد الإلكتروني مطلوب";
                                    }

                                    final emailPattern = RegExp(r'^[a-z0-9A-Z_.-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,3}$');

                                    if (!emailPattern.hasMatch(value)) {
                                      return 'أدخل البريد الإلكتروني بالشكل الصحيح (example@example.com)';
                                    }

                                    return null;
                                  }



                              ),
                            )),

                        SizedBox(
                          height: 23,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFF6db881),
                                  size: 19,
                                ),
                                labelText: "كلمة المرور:",
                                labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                hintText:
                                "كلمة المرور يجب ان تكون من 8 خانات وتشمل على حرف كبير ورمز مميز ",
                                hintStyle: TextStyle(fontSize: 10),
                                fillColor: Color(0xFFdff1e0),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(66.0),
                                  borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                ),
                              ),
                              validator: (value) {
                                RegExp uper = RegExp(r"(?=.*[A-Z])");
                                RegExp numb = RegExp(r"[0-9]");
                                RegExp small = RegExp(r"(?=.*[a-z])");
                                RegExp special = RegExp(r"(?=.*[!@#%^&*(),.?\\:{}|<>])");

                                if (value!.isEmpty || _passwordController.text.trim() == "") {
                                  return "كلمة السر مطلوبة";
                                }

                                String errorMessage = "";

                                if (value.length < 8) {
                                  errorMessage += "كلمة المرور يجب ان تكون من 8 خانات و";
                                }

                                if (!uper.hasMatch(value)) {
                                  errorMessage += "تحتوي على حرف كبير و";
                                }

                                if (!small.hasMatch(value)) {
                                  errorMessage += "تحتوي على أحرف صغيرة و";
                                }

                                if (!numb.hasMatch(value)) {
                                  errorMessage += "تحتوي على أرقام و";
                                }

                                if (!special.hasMatch(value)) {
                                  errorMessage += "تحتوي على رمز مميز و";
                                }

                                if (errorMessage.isNotEmpty) {
                                  errorMessage = errorMessage.substring(0, errorMessage.length - 2); // Remove the trailing "و"
                                  return errorMessage;
                                }

                                // If none of the above conditions are met, return null (no error message).
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
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextFormField(
                                  obscureText: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    //suffix: Icon(
                                    // Icons.visibility,
                                    // color: Color.fromARGB(
                                    // 255, 127, 166, 233),
                                    //  ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Color(0xFF6db881),
                                      size: 19,
                                    ),
                                    labelText: "تأكيد كلمة المرور:",
                                    labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                                    fillColor: Color(0xFFdff1e0),
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(66.0),
                                        borderSide:
                                        const BorderSide(width: 0, style: BorderStyle.none)),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "تأكيد كلمة المرور مطلوب ";
                                    } else if (value != _passwordController.text.trim()) {
                                      return "كلمة المرور غير مطابقة ";
                                    }
                                  }),
                            )),
                        SizedBox(
                          height: 25,
                        ),
                       ElevatedButton(
                          onPressed: () async {
                            try {
                              if (signformkey.currentState!.validate()) {
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim())
                                    .then((value) {
                                  final suser = SUser(
                                    name: _usernameController.text,
                                    email: _emailController.text,
                                  ); //creat user in database
                                  Fluttertoast.showToast(
                                    msg: "تم تسجيل حسابك بنجاح",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                    textColor: Color.fromARGB(255, 248, 249, 250),
                                    fontSize: 18.0,
                                  );
                                  createSuhailuser(suser);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => citiesPage()));
                                });
                              }
                            } on FirebaseAuthException catch (error) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text(
                                        "البريد الألكتروني موجود مسبقاً",
                                        style: TextStyle(fontFamily: "Tajawal-m", fontSize: 17),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            "حسناً",
                                            style: TextStyle(
                                              fontFamily: "Tajawal-m",
                                              fontSize: 17,
                                              color: Color(0xFF6db881),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Color(0xFF6db881)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(27))),
                          ),
                          child: Text(
                            "إنشاء حساب",
                            style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
                          ),
                        ),



                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/login");
                                },
                                child: Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Tajawal-b",
                                    color: Color(0xFF6db881),
                                  ),
                                ),
                              ),
                              Text(
                                "  لديك حساب ؟     ",
                                style: TextStyle(fontSize: 14, fontFamily: "Tajawal-l"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
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


Future createSuhailuser(SUser suser) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;
  final Uid = user!.uid;
  suser.userid = Uid;
  final json = suser.toJson();
  final docsuser = FirebaseFirestore.instance.collection('users').doc(Uid);
  await docsuser.set(json);
}


class SUser {
  late String userid;
  late final String name;
  late final String email;

  SUser({
    this.userid = '',
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() =>
      {
        'userId': userid,
        'name': name,
        'Email': email,
      };

  static SUser fromJson(Map<String, dynamic> json) =>
      SUser(
        userid: json['userId'],
        name: json['name'],
        email: json['Email'],
      );
}