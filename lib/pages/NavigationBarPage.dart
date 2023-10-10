import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'FavoritePage.dart';
import 'HomePage.dart';
import 'AddPage.dart';
import 'UserProfilePage.dart';
import '../Registration/logIn.dart';
class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({Key? key}) : super(key: key);

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(currentIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the circular "Add" button click here.
          // For example, navigate to the "AddPage" when clicked.
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPage()));
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
            label: 'الرئيسة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'الخريطة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
        selectedItemColor: Color(0xFF6db881),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return Container(); // Replace with your actual map page.
      case 2:
        return FavoritePage();
      case 3:
        return UserProfilePage();
      default:
        return HomePage();
    }
  }
}
