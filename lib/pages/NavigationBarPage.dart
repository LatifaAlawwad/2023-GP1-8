import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'FavoritePage.dart';
import 'HomePage.dart';
import 'addpage.dart';
import 'UserProfilePage.dart';
import '../Registration/logIn.dart';
class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({Key? key}) : super(key: key);

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    UserProfilePage(),
    FavoritePage(),

     addpage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentIndex = 3;
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6db881),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'إضافة',
          ),
        ],
        selectedItemColor: Color(0xFF6db881),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
