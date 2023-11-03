import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {

}

class Place {
  final String name;
  final double latitude;
  final double longitude;
  final String category;

  Place({
  required this.name,
  required this.latitude,
  required this.longitude,
  required this.category,
});
}

class MapPage extends StatefulWidget {


  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  List<Place> _places = [];
  LatLng _userLocation = LatLng(0.0, 0.0);
  String _selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchDataFromFirestore();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _fetchDataFromFirestore() async {
    QuerySnapshot snapshot = await _firestore.collection('PendingPlaces').get();

    _places = snapshot.docs
        .map((doc) =>
        Place(
          name: doc['placeName'],
          latitude: doc['latitude'],
          longitude: doc['longitude'],
          category: doc['category'],
        ))
        .toList();

    _sortPlacesByProximity();
  }

  void _sortPlacesByProximity() {
    _places.sort((a, b) {
      double distanceToA = Geolocator.distanceBetween(
        _userLocation.latitude,
        _userLocation.longitude,
        a.latitude,
        a.longitude,
      );
      double distanceToB = Geolocator.distanceBetween(
        _userLocation.latitude,
        _userLocation.longitude,
        b.latitude,
        b.longitude,
      );

      return distanceToA.compareTo(distanceToB);
    });

    setState(() {});
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _sortPlacesByProximity();
    });
  }

  String _getDistance(double latitude, double longitude) {
    double distance = Geolocator.distanceBetween(
      _userLocation.latitude,
      _userLocation.longitude,
      latitude,
      longitude,
    );
    return (distance / 1000).toStringAsFixed(2) + " km";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? category) {
                if (category != null) {
                  _filterByCategory(category);
                }
              },
              items: [
                'الكل',
                'مطاعم',
                'فعاليات و ترفيه',
                'مراكز تسوق',
              ]
                  .map((category) =>
                  DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
                  .toList(),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: Set<Marker>.from(_places
                  .where((place) =>
              _selectedCategory == 'الكل' ||
                  place.category == _selectedCategory)
                  .map((place) {
                return Marker(
                  markerId: MarkerId(place.name),
                  position: LatLng(place.latitude, place.longitude),
                  infoWindow: InfoWindow(
                    title: place.name,
                    snippet: _getDistance(place.latitude, place.longitude),
                  ),
                );
              }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
