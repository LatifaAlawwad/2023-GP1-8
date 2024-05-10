// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gp/Registration/First.dart';
import 'package:gp/Registration/RessetPassword.dart';
import 'package:gp/Registration/Welcome.dart';
import 'package:gp/Registration/SignUp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gp/Registration/logIn.dart';
import 'package:gp/language_constants.dart';
import 'package:gp/pages/NavigationBarPage.dart';
import 'package:gp/pages/citiesPage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gp/language_constants.dart';
import 'pages/MapView.dart';
import 'package:gp/pages/pref.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale (BuildContext context, Locale newLocale){
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);

  }
}


class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => setLocale(locale));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,

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
        '/MapPage': (context) => MapSample(),
        '/NavigationBarPage': (context) {
          String selectedCity = '';
          return NavigationBarPage(selectedCity: selectedCity);
        },




      },
    );
  }
}

