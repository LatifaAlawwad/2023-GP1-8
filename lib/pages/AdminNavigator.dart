import 'package:flutter/material.dart';
import 'AdminProfilePage.dart';
import 'AdminHomePage.dart';
import 'AdminRequestsPage.dart';

class AdminNavigator extends StatefulWidget {
  @override
  _AdminNavigatorState createState() => _AdminNavigatorState();
}

class _AdminNavigatorState extends State<AdminNavigator> {
  int currentIndex = 0;

  final List<Widget> _pages = [
    AdminHomePage(),
    AdminProfilePage(),
    AdminRequestsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(currentIndex),
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
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'طلبات الإضافة',
          ),
        ],
        selectedItemColor: Color(0xFF6db881),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _getPage(int index) {
    return _pages[index];
  }
}
