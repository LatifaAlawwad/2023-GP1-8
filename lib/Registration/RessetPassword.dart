
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/Registration/logIn.dart';
import 'package:gp/language_constants.dart';

class RessetPassword extends StatefulWidget {
  const RessetPassword({Key? key}) : super(key: key);

  @override
  State<RessetPassword> createState() => _RessetPasswordState();
}

class _RessetPasswordState extends State<RessetPassword> {
  final email = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }
//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6db881),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 115),
          child: Text(
            translation(context).restorePass,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Tajawal-b",
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              translation(context).eneterEmail,
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Tajawal-b",
                color: Color(0xFF6db881), // Use your sign-in color here
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 15,
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
                  labelText: translation(context).email,
                  labelStyle: TextStyle(fontFamily: "Tajawal-m"),
                  hintText: "example@gmail.com",
                  hintStyle: TextStyle(fontSize: 10),
                  fillColor: Color(0xFFe1e1e4),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(66.0),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || email.text.trim() == "") {
                    return translation(context).reqEmail;
                  } else if (!RegExp(
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                      .hasMatch(value)) {
                    return translation(context).correctEmail;
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email.text);
                Fluttertoast.showToast(
                  msg: translation(context).sentLink,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 4,
                  backgroundColor: Color(0xFF6db881),
                  textColor: Color(0xFFF8F9FA),
                  fontSize: 18.0,
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return LogIn();
                }));
              } on FirebaseAuthException catch (e) {
                Fluttertoast.showToast(
                  msg: translation(context).notRegEmail,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Color(0xFF6db881),
                  textColor: Color(0xFFF8F9FA),
                  fontSize: 18.0,
                );
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF6db881)),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
            ),
            child: Text(
              translation(context).sent,
              style: TextStyle(fontSize: 20, fontFamily: "Tajawal-l"),
            ),
          ),
        ],
      ),
    );
  }
}
