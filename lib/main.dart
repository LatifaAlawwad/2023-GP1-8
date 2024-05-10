// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gp/Registration/First.dart';
import 'package:gp/Registration/RessetPassword.dart';
import 'package:gp/Registration/Welcome.dart';
import 'package:gp/Registration/SignUp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gp/Registration/logIn.dart';
import 'package:gp/pages/NavigationBarPage.dart';
import 'package:gp/pages/citiesPage.dart';
import 'package:gp/pages/pref.dart';

import 'pages/MapView.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/first',
      routes: {
        '/pref': (context) => pref(),
        '/first': (context) => First(),
        '/welcome': (context) => Welcome(),
        '/signup': (context) => SignUp(),
        '/login': (context) => LogIn(),
        '/RessetPassword': (context) => RessetPassword(),
        '/citiesPage': (context) => CitiesPage(),
        // Use 'CitiesPage' here and pass 'selectedCity' as needed
        '/MapPage': (context) =>  MapSample(),

        '/NavigationBarPage': (context) {
          String selectedCity ='';
          return NavigationBarPage(selectedCity: selectedCity);
        },

      },
    );
  }
}
