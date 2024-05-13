import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:ui' as ui;

const String LANGUAGE_CODE = 'languageCode';

const String ENGLISH = 'en';
const String ARABIC = 'ar';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? ARABIC;
  return _locale(languageCode);
}

Locale _locale (String languageCode ){
  switch (languageCode){
    case ENGLISH:
      return Locale(ENGLISH,'US');
    case ARABIC:
      return Locale(ARABIC,'SA');
    default:
      return Locale(ARABIC,'SA');
  }
}

AppLocalizations translation (BuildContext context){
  return AppLocalizations.of(context)! ;

}

bool isArabic() {
  Locale currentLocale = ui.window.locale;
  return currentLocale.languageCode == ARABIC;
}

bool isEnglish() {
  Locale currentLocale = ui.window.locale;
  return currentLocale.languageCode == ENGLISH;
}