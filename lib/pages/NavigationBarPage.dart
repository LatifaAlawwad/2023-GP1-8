import 'package:flutter/material.dart';
import 'MapView.dart';
import 'FavoritePage.dart';
import 'HomePage.dart';
import 'addpage.dart';
import 'UserProfilePage.dart';

import 'package:gp/language_constants.dart';

class NavigationBarPage extends StatefulWidget {
   final String selectedCity; // Add selectedCity property

  const NavigationBarPage({Key? key, required this.selectedCity}) : super(key: key);

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}


class _NavigationBarPageState extends State<NavigationBarPage> {
  int currentIndex = 0;
  bool showLabel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              _buildIconButtonWithLabel(Icons.home, translation(context).mainPage  , 0),
              _buildIconButtonWithLabel(Icons.map, translation(context).mapPage , 1),
              SizedBox(width: 48.0),
              _buildIconButtonWithLabel(Icons.favorite, translation(context).favPage , 2),
              _buildIconButtonWithLabel(Icons.person, translation(context).profilePage , 3),
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
        return HomePage(cityName: widget.selectedCity, cityId: 3);
      case 1:
        return MapSample();
      case 2:
        return FavoritePage();
      case 3:
        return UserProfilePage(cityName: widget.selectedCity);
      default:
        return HomePage(cityName: '', cityId: 18);
    }
  }

}
