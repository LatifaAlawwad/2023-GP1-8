import 'package:flutter/material.dart';
import 'package:gp/language_constants.dart';
import '../main.dart';
import '../Language.dart';

class SwitchLanguage extends StatefulWidget {
  @override
  _SwitchLanguageState createState() => _SwitchLanguageState();
}

class _SwitchLanguageState extends State<SwitchLanguage> {
  Language? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void _loadSelectedLanguage() async {
    Locale currentLocale = await getLocale();
    Language selectedLanguage = Language.languageList().firstWhere(
          (language) => language.languageCode == currentLocale.languageCode,
      // Default language if not found
    );

    setState(() {
      _selectedLanguage = selectedLanguage;
    });
  }

  void _selectLanguage(Language language) {
    setState(() {
      _selectedLanguage = language;
    });
    Locale selectedLocale = Locale(language.languageCode);
    MyApp.setLocale(context, selectedLocale);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 109, 184, 129),
          automaticallyImplyLeading: false,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                translation(context).lang,
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: "Tajawal-b",
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
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
        body: ListView.separated(
          itemCount: Language.languageList().length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
          itemBuilder: (context, index) {
            Language language = Language.languageList()[index];
            bool isSelected = language.languageCode == _selectedLanguage?.languageCode;

            return ListTile(
              onTap: () {
                _selectLanguage(language);
              },
              title: Text(language.name),
              trailing: isSelected ? Icon(Icons.check) : null,
            );
          },
        ),
      ),
    );
  }
}