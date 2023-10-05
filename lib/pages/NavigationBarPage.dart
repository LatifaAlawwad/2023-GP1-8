import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'addpage.dart';
import 'UserProfilePage.dart';

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
    Center(child: Text('المفضلة')),
    addpage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سهيل'),
        backgroundColor: Color(0xFF6db881),
        centerTitle: true,
      ),
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
