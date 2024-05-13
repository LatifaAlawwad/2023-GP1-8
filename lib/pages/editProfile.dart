import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp/language_constants.dart';
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0,right:10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Text(
              translation(context).modifyPerInfo,
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Tajawal-b",
              ),
            ),
            SizedBox(width: 40), // Adjust the width based on your preference
          ],
        ),
        centerTitle: false, // Ensure the title is aligned based on Row alignment
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

                                Center( // Wrap with Center widget

                                    child: Text(
                                      translation(context).personalInfo,
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
                                  child: Row(
                                    mainAxisAlignment: isArabic() ? MainAxisAlignment.start : MainAxisAlignment.end,
                                    children: [
                                      Expanded(

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
                                              errorStyle: TextStyle(
                                                color: Color.fromARGB(255, 196, 51, 51),
                                                fontSize: 14.0,
                                              ),
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: isArabic() ? 0 : 16,
                                                vertical: 16,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.length < 2) {
                                                return translation(context).nameCon;
                                              }
                                              if (RegExp(r'[0-9]').hasMatch(value)) {
                                                return translation(context).onlyletters;
                                              }
                                            },
                                          ),

                                      ),
                                    ],
                                  ),
                                ),





                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: isArabic() ? MainAxisAlignment.start : MainAxisAlignment.end,
                                    children: [
                                   Expanded(
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
                                    ],
                                  ),
                                ),

                                // New Password Fields
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        translation(context).updatePass,
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
                                  child: Row(
                                      mainAxisAlignment: isArabic() ? MainAxisAlignment.start : MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: currentPasswordController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      focusNode: currentPasswordFocusNode,
                                      decoration: InputDecoration(
                                        hintText: translation(context).currentPass,
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
                                    ),),]
                                  ),
                                ),

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: !isCurrentPasswordValid,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                          child: Text(
                                            translation(context).wrongCurPass,
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 196, 51, 51),
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
                                  child: Row(
                                      mainAxisAlignment: isArabic() ? MainAxisAlignment.start : MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: newPasswordController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,

                                      decoration: InputDecoration(
                                        hintText: translation(context).newPass,
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
                                          color: Color.fromARGB(255, 196, 51, 51),
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      validator: (value) {
                                        RegExp upper = RegExp(r"(?=.*[A-Z])");
                                        RegExp number = RegExp(r"[0-9]");
                                        RegExp lower = RegExp(r"(?=.*[a-z])");
                                        RegExp special = RegExp(r"(?=.*[!@#%^&*(),.?\\:{}|<>])");

                                        if (value!.isEmpty) {
                                          return null;
                                        }

                                        String errorMessage = "";

                                        if (value.length < 8) {
                                          errorMessage += translation(context).eightchar;
                                        }

                                        if (!upper.hasMatch(value)) {
                                          errorMessage += translation(context).capletter;
                                        }

                                        if (!lower.hasMatch(value)) {
                                          errorMessage += translation(context).smaletter;
                                        }

                                        if (!number.hasMatch(value)) {
                                          errorMessage += translation(context).conNum;
                                        }

                                        if (!special.hasMatch(value)) {
                                          errorMessage += translation(context).specialchar;
                                        }

                                        if (errorMessage.isNotEmpty) {
                                          errorMessage = errorMessage.trim();
                                          return errorMessage;
                                        }

                                        // If none of the above conditions are met, return null (no error message).
                                        return null;
                                      },
                                    ),),]
                                  ),


                                ),
                                SizedBox(
                                  height: 10,
                                ),


                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                      mainAxisAlignment: isArabic() ? MainAxisAlignment.start : MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: confirmPasswordController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      focusNode: confirmedPasswordFocusNode,
                                      decoration: InputDecoration(
                                        hintText: translation(context).conPass,
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
                                    ),),]
                                  ),
                                ),



                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: !isPasswordMatch,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:30),
                                          child: Text(
                                            translation(context).unmatchPass,
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
                                                msg: translation(context).succUpdate,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 2,
                                                backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                textColor: Color.fromARGB(255, 248, 249, 250),
                                                fontSize: 18.0,
                                              );
                                            } catch (e, stack) {
                                              Fluttertoast.showToast(
                                                msg: translation(context).errorOcur,
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
                                                          msg: translation(context).succUpdate,
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
                                                          msg: "${translation(context).errorUpPass} ${e.message}",
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
                                                        msg: translation(context).newAndconPassUNMATH,
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
                                                      msg: translation(context).curANDnewPass,
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
                                                    msg: translation(context).rightCurrPass,
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 5,
                                                    backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                    textColor: Color.fromARGB(255, 252, 253, 255),
                                                    fontSize: 18.0,
                                                  );}
                                                }else {

                                                  Fluttertoast.showToast(
                                                    msg: translation(context).fillCurrPass,
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
                                                  msg: translation(context).fillConPass,
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 5,
                                                  backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                  textColor: Color.fromARGB(255, 252, 253, 255),
                                                  fontSize: 18.0,
                                                );

                                              }else if( confirmPasswordController.text.isNotEmpty && newPasswordController.text.isEmpty){
                                                Fluttertoast.showToast(
                                                  msg: translation(context).fillNewPass,
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 5,
                                                  backgroundColor: Color.fromARGB(255, 109, 184, 129),
                                                  textColor: Color.fromARGB(255, 252, 253, 255),
                                                  fontSize: 18.0,
                                                );
                                              }else{
                                                Fluttertoast.showToast(
                                                  msg: translation(context).newPassCondition,
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
                                          msg: translation(context).newPassMatch,
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
                                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        ),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(27),
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          translation(context).saveChanges,
                                          style: TextStyle(fontSize: 18, fontFamily: "Tajawal-m"),
                                        ),
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