import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Registration/SignUp.dart';
import '../Registration/logIn.dart';

class editProfile extends StatefulWidget {
  const editProfile({Key? key}) : super(key: key);

  @override
  State<editProfile> createState() => _editProfileState();
}

late FirebaseAuth auth = FirebaseAuth.instance;
late User? user = auth.currentUser;
late String curentId = user!.uid;

class _editProfileState extends State<editProfile> {
  final profileformkey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  FocusNode currentPasswordFocusNode = FocusNode();
  FocusNode confirmedPasswordFocusNode = FocusNode();
  late bool isCurrentPasswordValid = true;
  late bool isPasswordMatch = true;
  late bool isPasswordValid = true;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    curentId = user!.uid;
    isCurrentPasswordValid = true;
    isPasswordMatch = true;
    currentPasswordFocusNode.addListener(() {
      if (!currentPasswordFocusNode.hasFocus) {
        _checkPassword(user!.email!);
      }

    });


    confirmedPasswordFocusNode.addListener(() {
      if (!confirmedPasswordFocusNode.hasFocus) {
        _isConfirmed();
      }

    });

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 184, 129),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Text(
            "تعديل المعلومات الشخصية ",
            style: TextStyle(
              fontSize: 17,
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
        toolbarHeight: 60,
      ),
      body:  SafeArea(
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
                            if (snapshot.hasError) {

                              return Text('Error: ${snapshot.error}');
                            }

                            final cuuser = snapshot.data;

                            if (cuuser == null) {
                              // Handle the case when data is null
                              return Text('');
                            }

                            final nameControlar = TextEditingController(text: cuuser.name);
                            final emailcontrolar = TextEditingController(text: cuuser.email);

                            return Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "المعلومات الشخصية",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 109, 184, 129),
                                      fontFamily: "Tajawal-b",
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TextFormField(
                                      controller: nameControlar,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        fillColor: Color.fromARGB(255, 225, 225, 228),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(66.0),
                                          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value!.length < 2) {
                                          return "الأسم يجب ان يكون خانتين فأكثر ";
                                        }
                                        if (RegExp(r'[0-9]').hasMatch(value)) {
                                          return 'الرجاء إدخال أحرف فقط';
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: emailcontrolar,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        fillColor: Color.fromARGB(255, 225, 225, 228),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(66.0),
                                          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // New Password Fields
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "تحديث كلمة المرور",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 134, 134, 134),
                                          fontFamily: "Tajawal-b",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: currentPasswordController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      focusNode: currentPasswordFocusNode,
                                      decoration: InputDecoration(
                                        hintText: 'كلمة المرور الحالية',
                                        prefixIcon: Icon(
                                          Icons.lock_open,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        fillColor: Color.fromARGB(255, 225, 225, 228),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(66.0),
                                          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible: !isCurrentPasswordValid,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:30),
                                          child: Text(
                                            "كلمة المرور الحالية غير صحيحة",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 196, 51, 51),
                                              fontSize: 14,
                                            ),


                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: newPasswordController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        hintText: 'كلمة المرور الجديدة',
                                        prefixIcon: Icon(
                                          Icons.password_rounded,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        fillColor: Color.fromARGB(255, 225, 225, 228),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(66.0),
                                          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                        ),
                                        errorStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 196, 51, 51),
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      validator: (value) {
                                        RegExp uper = RegExp(r"(?=.*[A-Z])");
                                        RegExp numb = RegExp(r"[0-9]");
                                        RegExp small = RegExp(r"(?=.*[a-z])");
                                        RegExp special = RegExp(r"(?=.*[!@#%^&*(),.?\\:{}|<>])");

                                        if (value!.isEmpty) {
                                          return null;
                                        }

                                        String errorMessage = "";

                                        if (value.length < 8) {
                                          errorMessage += "\u2022 كلمة المرور يجب أن تكون من 8 خانات\n";
                                        }

                                        if (!uper.hasMatch(value)) {
                                          errorMessage += "\u2022 تحتوي على حرف كبير\n";
                                        }

                                        if (!small.hasMatch(value)) {
                                          errorMessage += "\u2022 تحتوي على أحرف صغيرة\n";
                                        }

                                        if (!numb.hasMatch(value)) {
                                          errorMessage += "\u2022 تحتوي على أرقام\n";
                                        }

                                        if (!special.hasMatch(value)) {
                                          errorMessage += "\u2022 تحتوي على رمز مميز\n";
                                        }

                                        if (errorMessage.isNotEmpty) {
                                          errorMessage = errorMessage.trim();
                                          return errorMessage;
                                        }

                                        // If none of the above conditions are met, return null (no error message).
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),


                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: confirmPasswordController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      focusNode: confirmedPasswordFocusNode,
                                      decoration: InputDecoration(
                                        hintText: 'تأكيد كلمة المرور',
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        fillColor: Color.fromARGB(255, 225, 225, 228),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(66.0),
                                          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),



                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible: !isPasswordMatch,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:30),
                                          child: Text(
                                            "كلمة المرور غير متطابقة",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 196, 51, 51),
                                              fontSize: 14,
                                            ),


                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 100,
                                ),
                                SizedBox(
                                  width: 210.0,
                                  height: 70.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        bool isPasswordFieldsEmpty =
                                                currentPasswordController.text.isEmpty &&
                                                newPasswordController.text.isEmpty &&
                                                confirmPasswordController.text.isEmpty;

                                        if (profileformkey.currentState!.validate()) {
                                          if (isPasswordFieldsEmpty) {
                                            // All password fields are empty, save the name directly
                                            try {
                                              FirebaseFirestore.instance.collection('users').doc(curentId).update({
                                                'name': nameControlar.text,
                                              });

                                              Fluttertoast.showToast(
                                                msg: "تم التحديث بنجاح",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 2,
                                                backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                textColor: Color.fromARGB(255, 248, 249, 250),
                                                fontSize: 18.0,
                                              );
                                            } catch (e, stack) {
                                              Fluttertoast.showToast(
                                                msg: "حدث خطأ أثناء تحديث المعلومات الشخصية",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 5,
                                                backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                textColor: Color.fromARGB(255, 252, 253, 255),
                                                fontSize: 18.0,
                                              );
                                            }
                                          } else {




                                              if (newPasswordController.text.isNotEmpty &&
                                                  confirmPasswordController.text.isNotEmpty) {

                                                if (currentPasswordController.text.isNotEmpty){

                                                  if(isCurrentPasswordValid){
                                                  if (newPasswordController.text != currentPasswordController.text) {
                                                    if (newPasswordController
                                                        .text ==
                                                        confirmPasswordController
                                                            .text) {
                                                      try {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(curentId)
                                                            .update({
                                                          'name': nameControlar
                                                              .text,
                                                        });
                                                        await auth.currentUser!
                                                            .updatePassword(
                                                            newPasswordController
                                                                .text);

                                                        Fluttertoast.showToast(
                                                          msg: "تم التحديث بنجاح",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          timeInSecForIosWeb: 2,
                                                          backgroundColor: Color
                                                              .fromARGB(
                                                              255, 109, 184,
                                                              129),
                                                          textColor: Color
                                                              .fromARGB(
                                                              255, 248, 249,
                                                              250),
                                                          fontSize: 18.0,
                                                        );
                                                      } on FirebaseAuthException catch (e) {
                                                        Fluttertoast.showToast(
                                                          msg: "خطأ في تحديث كلمة المرور: ${e
                                                              .message}",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          timeInSecForIosWeb: 5,
                                                          backgroundColor: Color
                                                              .fromARGB(
                                                              255, 109, 184,
                                                              129),
                                                          textColor: Color
                                                              .fromARGB(
                                                              255, 252, 253,
                                                              255),
                                                          fontSize: 18.0,
                                                        );
                                                      }
                                                    }


                                                    else {
                                                      Fluttertoast.showToast(
                                                        msg: "كلمة المرور الجديدة وتأكيد كلمة المرور غير متطابقتين",
                                                        toastLength: Toast
                                                            .LENGTH_SHORT,
                                                        gravity: ToastGravity
                                                            .CENTER,
                                                        timeInSecForIosWeb: 5,
                                                        backgroundColor: Color
                                                            .fromARGB(
                                                            255, 109, 184, 129),
                                                        textColor: Color
                                                            .fromARGB(
                                                            255, 252, 253, 255),
                                                        fontSize: 18.0,
                                                      );
                                                    }
                                                  }else {


                                                    Fluttertoast.showToast(
                                                      msg: "يجب ان تكون كلمة المرور الحالية و الجديدة غير متطابقتين",
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 5,
                                                      backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                      textColor: Color.fromARGB(255, 252, 253, 255),
                                                      fontSize: 18.0,
                                                    );
                                                  }

                                                  } else {
                                                    Fluttertoast.showToast(
                                                    msg: "لتغيير كلمة المرور، يجب ان تكون كلمة المرور الحالية صحيحة",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 5,
                                                    backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                    textColor: Color.fromARGB(255, 252, 253, 255),
                                                    fontSize: 18.0,
                                                  );}
                                                }else {

                                                  Fluttertoast.showToast(
                                                    msg: "لتغيير كلمة المرور، يجب ملء حقل كلمة المرور الحالية",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 5,
                                                    backgroundColor: Colors.red,
                                                    textColor: Color.fromARGB(255, 252, 253, 255),
                                                    fontSize: 18.0,
                                                  );
                                                }
                                              }else if (confirmPasswordController.text.isEmpty && newPasswordController.text.isNotEmpty){

                                                Fluttertoast.showToast(
                                                  msg: "لتغيير كلمة المرور، يجب ملء حقل تأكيد كلمة المرور",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 5,
                                                  backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                  textColor: Color.fromARGB(255, 252, 253, 255),
                                                  fontSize: 18.0,
                                                );

                                              }else if( confirmPasswordController.text.isNotEmpty && newPasswordController.text.isEmpty){
                                                Fluttertoast.showToast(
                                                  msg: "لتغيير كلمة المرور، يجب ملء حقل كلمة المرور الجديدة",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 5,
                                                  backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                  textColor: Color.fromARGB(255, 252, 253, 255),
                                                  fontSize: 18.0,
                                                );
                                              }else{
                                                Fluttertoast.showToast(
                                                  msg: "لتغيير كلمة المرور، يجب ملء حقل كلمة المرور الجديدة وتأكيد كلمة المرور",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 5,
                                                  backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                  textColor: Color.fromARGB(255, 252, 253, 255),
                                                  fontSize: 18.0,
                                                );

                                              }
                                            }

                                        }else {  Fluttertoast.showToast(
                                          msg: "لتغيير كلمة المرور، يجب ان تكون كلمة المرور تطابق الشروط",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                          textColor: Color.fromARGB(255, 252, 253, 255),
                                          fontSize: 18.0,
                                        );}
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                          Color.fromARGB(255, 109, 184, 129),
                                        ),
                                        padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                        ),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(27),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "حفظ التغيرات",
                                        style: TextStyle(fontSize: 18, fontFamily: "Tajawal-m"),
                                      ),
                                    ),
                                  ),


                                ),
                              ],
                            );

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


  Future<void> _checkPassword(String email) async  {
    if (currentPasswordController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: currentPasswordController.text,
        );

        // Clear the error message
        setState(() {
          isCurrentPasswordValid = true;
        });
      } catch (e) {
        // Authentication failed
        setState(() {
          isCurrentPasswordValid = false;
        });
      }
    }
  }

  Future<void>  _isConfirmed()async  {
    if (confirmPasswordController.text.isNotEmpty) {

      if (newPasswordController.text == confirmPasswordController.text) {
        setState(() {
        isPasswordMatch = true;
        });
      } else {

        setState(() {
          isPasswordMatch = false;
        });

      }

    }
  }
}

Future getCurrentUser() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? suser = auth.currentUser;
  final Uid = suser!.uid;
  final docUser = await FirebaseFirestore.instance.collection('users').doc(Uid).get();
  if (docUser.exists) {
    return SUser.fromJson(docUser.data()!);
  }
}