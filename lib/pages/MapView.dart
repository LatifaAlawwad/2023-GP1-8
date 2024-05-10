import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

import 'package:gp/pages/placePage.dart';
import 'dart:math';
import 'package:gp/language_constants.dart';
import 'package:gp/pages/mapdetailspage.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();

  void onPressed() {}
}

class MapSampleState extends State<MapSample> {

  late BitmapDescriptor restIcon;
  late BitmapDescriptor mallIcon;
  late BitmapDescriptor entIcon;
  late BitmapDescriptor myIcon;

  late GoogleMapController _controller;
  String selectedCategory = 'الكل';
  List<placePage> allPlaces = [];
  late LatLng currentLatLng = LatLng(24.7136, 46.6753);
  List<placePage> filteredPlacesInfo = [];
  LatLng? droppedPin;
  final _firestore = FirebaseFirestore.instance;
  static final TextEditingController _startSearchFieldController =
  TextEditingController();
  DetailsResult? startPosition;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
    _loadCustomMarkerIcons();
    _goToCurrentLocation();
    selectedCategory = 'الكل';
    String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    googlePlace = GooglePlace(apiKey);
    getMarkers();
  }

  Future<void> _initializeCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    await _determinePosition();
    markers.clear();
    droppedPin = null;
    _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng!, zoom: 15)));
    getMarkers();
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
    return;
  }

  Future<void> _loadCustomMarkerIcons() async {
    restIcon = await _resizeImage('assets/images/rest.png', 160, 160);
    mallIcon = await _resizeImage('assets/images/mall.png', 160, 160);
    entIcon = await _resizeImage('assets/images/ent.png', 210, 210);
    myIcon = await _resizeImage('assets/images/marker.png', 160, 160);
  }
  Future<BitmapDescriptor> _resizeImage(String imagePath, int width, int height) async {
    ByteData imageData = await rootBundle.load(imagePath);
    Uint8List bytes = imageData.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width, targetHeight: height);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image image = frameInfo.image;

    ByteData? resizedImageData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List resizedBytes = resizedImageData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }


  Future<void> getMarkers() async {
    setState(() {
      filteredPlacesInfo.clear();
    });

    await for (var snapshot
    in _firestore.collection('ApprovedPlaces').snapshots()) {
      for (var place in snapshot.docs) {
        setState(() {
          String category = place['category'] ?? '';
          if (selectedCategory == 'الكل' || category == selectedCategory) {
            LatLng placeLatLng = LatLng(place['latitude'], place['longitude']);
            double distance =
            calculateDistance(droppedPin ?? currentLatLng, placeLatLng);

            // Display only markers within a certain distance (adjust the threshold as needed)
            if (distance <= 5.0) {
              markers.add(Marker(
                markerId: MarkerId(place['placeName']),
                position: placeLatLng,
                icon: getMarkerIcon(category),
                infoWindow: InfoWindow(
                  title: place['placeName'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => mapdetailspage(
                          place: placePage(
                            place_id: place['place_id'] ?? '',
                            userId: place['User_id'] ?? '',
                            placeName: place['placeName'] ?? '',
                            category: place['category'] ?? '',
                            type1: '',
                            city: place['city'] ?? '',
                            neighbourhood: place['neighbourhood'] ?? '',
                            images: List<String>.from(place['images']),
                            Location: place['WebLink'] ?? '',
                            description: place['description'] ?? '',
                            latitude: place['latitude'] ?? 0.0,
                            longitude: place['longitude'] ?? 0.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ));
              filteredPlacesInfo.add(placePage(
                place_id: place['place_id'] ?? '',
                userId: place['User_id'] ?? '',
                placeName: place['placeName'] ?? '',
                category: place['category'] ?? '',
                type1: '',
                city: place['city'] ?? '',
                neighbourhood: place['neighbourhood'] ?? '',
                images: List<String>.from(place['images']),
                Location: place['WebLink'] ?? '',
                description: place['description'] ?? '',
                latitude: place['latitude'] ?? 0.0,
                longitude: place['longitude'] ?? 0.0,
              ));
            }
          }
        });
      }
    }


    setState(() {
      droppedPin = null;
      displayFilteredPlacesList();
    });
  }

  //Calculate the distance
  double calculateDistance(LatLng? point1, LatLng point2) {
    const double earthRadius =
        6371; // Radius of the earth in kilometers (use 3959 for miles)

    double toRadians(double degree) {
      return degree * (pi / 180.0);
    }

    double lat1 = toRadians(point1!.latitude);
    double lon1 = toRadians(point1!.longitude);
    double lat2 = toRadians(point2.latitude);
    double lon2 = toRadians(point2.longitude);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distance in kilometers

    return distance;
  }




  changeLocation() async {
    double? lat = startPosition?.geometry?.location?.lat;
    double? lng = startPosition?.geometry?.location?.lng;
    _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat!, lng!), zoom: 14)));
    _startSearchFieldController.clear();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _goToCurrentLocation,
            child: Icon(Icons.my_location),
            backgroundColor: Color.fromARGB(255, 109, 184, 129),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: FloatingActionButton(
              onPressed: () {
                filterMap();
              },
              child: IconButton(
                iconSize: 30,
                icon: Icon(Icons.layers),
                onPressed: () {
                  showDropdownMenu(context);
                },
              ),
              backgroundColor: Color.fromARGB(255, 109, 184, 129),
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              displayFilteredPlacesList();
              widget.onPressed();
            },
            child: Icon(
              Icons.list,
              size: 30,
            ),
            backgroundColor: Color.fromARGB(255, 109, 184, 129),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, left: 0, right: 0),
            child: TextFormField(
              controller: _startSearchFieldController,
              decoration: InputDecoration(
                  hintText: translation(context).search,
                  hintStyle: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 202, 198, 198)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  suffixIcon: _startSearchFieldController.text.isEmpty
                      ? Icon(Icons.search,
                          color: Color.fromARGB(255, 109, 184, 129))
                      : IconButton(
                          icon: Icon(Icons.search,
                              color: Color.fromARGB(255, 109, 184, 129)),
                          onPressed: () {
                            changeLocation();
                          },
                        )),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    setState(() {
                      predictions = [];
                      startPosition = null;
                    });
                  }
                });
              },
            ),
          ),
          Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 109, 184, 129),
                    child: Icon(
                      Icons.pin_drop,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    predictions[index].description.toString(),
                  ),
                  onTap: () async {
                    final placeId = predictions[index].placeId!;
                    final details = await googlePlace.details.get(placeId);
                    if (details != null && details.result != null && mounted) {
                      setState(() {
                        startPosition = details.result;
                        _startSearchFieldController.text =
                            details.result!.name!;
                        predictions = [];
                      });
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(
                    () => new EagerGestureRecognizer()),
              ].toSet(),
              mapType: MapType.normal,
              onTap: (LatLng latLng) {
                setState(() {
                  droppedPin = latLng;
                  markers.clear(); // Clear existing markers
                  markers.add(Marker(
                    markerId: MarkerId('droppedPin'),
                    position: droppedPin!,
                    infoWindow: InfoWindow(title: 'Dropped Pin'),
                  ));
                  _controller
                      ?.animateCamera(CameraUpdate.newLatLng(droppedPin!));
                  getMarkers();
                });
              },
              markers: markers.toSet(),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _controller = controller;
                });
              },
              initialCameraPosition:
                  CameraPosition(target: currentLatLng!, zoom: 14),
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  void filterPlaces(String category) {
    setState(() {
      selectedCategory = category;
      markers.clear();
      allPlaces.clear();
    });
    getMarkers();
  }

  Widget filterMap() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translation(context).placeCategory,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Add your form elements here for selecting the category
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'Filtered!');
          },
          child: Text('Apply Filter'),
        ),
      ],
    );
  }

  void displayFilteredPlacesList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Scrollbar(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPlacesInfo.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlacesInfo[index];

                    return Card(
                      margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          _moveMapToPlace(place);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 210,
                          decoration: BoxDecoration(
                            image: place.images.isEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                        'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(place.images[0]),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.5, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${place.placeName}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Tajawal-l",
                                      ),
                                    ),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: "Tajawal-l",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${place.neighbourhood}, ${place.city}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Tajawal-l",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BitmapDescriptor getMarkerIcon(String category) {
    switch (category) {
      case 'فعاليات و ترفيه':
        return entIcon;
      case 'مطاعم':
        return restIcon;
      case 'مراكز تسوق':
        return mallIcon;
      default:
        return myIcon; // Use a default icon for unknown categories
    }
  }

  void showDropdownMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translation(context).placeClass,
                  style: TextStyle(
                    color: Color.fromARGB(255, 109, 184, 129),
                  )),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCategory,
                  items: <String>[
                translation(context).all,
              translation(context).ent,
              translation(context).rest,
              translation(context).mall
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value,
                              style: TextStyle(
                                color: Color.fromARGB(255, 109, 184, 129),
                              )),
                          // Add an icon based on the category
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      filterPlaces(newValue);
                      Navigator.pop(context); // Close the first dropdown
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _moveMapToPlace(placePage place) async {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.latitude, place.longitude),
          zoom: 14,
        ),
      ),
    );
  }
}

class PlaceInfo {
  final String placeName;
  final double distance;

  PlaceInfo({
    required this.placeName,
    required this.distance,
  });
}
