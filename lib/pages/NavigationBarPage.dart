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
  bool showLabel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(currentIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6db881),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 77.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButtonWithLabel(Icons.home, 'الرئيسة', 0),
              _buildIconButtonWithLabel(Icons.map, 'الخريطة', 1),
              SizedBox(width: 48.0),
              _buildIconButtonWithLabel(Icons.favorite, 'المفضلة', 2),
              _buildIconButtonWithLabel(Icons.person, 'حسابي', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButtonWithLabel(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        _selectTab(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            color: currentIndex == index ? Color(0xFF6db881) : Colors.grey,
            onPressed: () => _selectTab(index),
          ),
          Visibility(
            visible: currentIndex == index,
            child: SizedBox(height: 8.0),
          ),
          Visibility(
            visible: currentIndex == index,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: currentIndex == index ? Color(0xFF6db881) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      currentIndex = index;
    });
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
