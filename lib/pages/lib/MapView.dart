import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:gp/pages/placeDetailsPage.dart';
import 'package:gp/pages/placePage.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();

  void onPressed() {}
}

class MapSampleState extends State<MapSample> {
  void onPressed() {
    print('Button Pressed');
  }


  Completer<GoogleMapController> _controller = Completer();

  void _initializeCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }}

  String selectedCategory = 'الكل';

  List<placePage> allPlaces = [];
  late LatLng currentLatLng = const LatLng(24.7136, 46.6753);
  List<placePage> filteredPlacesInfo = [];

  @override
  void initState() {
    _initializeCurrentLocation();
    _handleLocationPermission();
    _goToCurrentLocation();
    selectedCategory = 'الكل';

    String apiKey = 'AIzaSyCOT8waQ9GpvCUwXotTCZD9kSPfN8JljNk';
    googlePlace = GooglePlace(apiKey);
    getMarkers();
    super.initState();
  }

  final _firestore = FirebaseFirestore.instance;
  List<Marker> markers = [];
  static final TextEditingController _startSearchFieldController =
  TextEditingController();

  DetailsResult? startPosition;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;


  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
    return;
  }

  Future<void> _goToCurrentLocation() async {
    await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: currentLatLng, zoom: 15)));
  }

  Future getMarkers() async {
    setState((){ filteredPlacesInfo = [] ;});
    await for (var snapshot in _firestore.collection('PendingPlaces').snapshots())
      for (var place in snapshot.docs) {
        setState(() {
          String category = place['category'] ?? '';
          if (selectedCategory == 'الكل' || category == selectedCategory){
            markers.add(Marker(
              markerId: MarkerId(place['placeName']),
              position: new LatLng(place['latitude'], place['longitude']),
              infoWindow: InfoWindow(
                  title: place['placeName'],
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => placeDetailsPage(
                              place: placePage(
                                place_id: place['place_id'] ?? '',
                                userId: place['User_id'] ?? '',
                                placeName: place['placeName'] ?? '',
                                category: place['category'] ?? '',
                                type1: '',
                                city: place['city'] ?? '',
                                neighbourhood: place['neighbourhood'] ?? '',
                                images: List<String>.from(place['images']),
                                Location: place['Location'] ?? '',
                                description: place['description'] ?? '',
                                latitude: place['latitude'] ?? 0.0,
                                longitude: place['longitude'] ?? 0.0,
                              ),
                            )));
                  }),
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
            Location: place['Location'] ?? '',
            description: place['description'] ?? '',
            latitude: place['latitude'] ?? 0.0,
            longitude: place['longitude'] ?? 0.0,
          )); }

      });
  }}

  changeLocation() async {
    final GoogleMapController controller = await _controller.future;
    double? lat = startPosition?.geometry?.location?.lat;
    double? lng = startPosition?.geometry?.location?.lng;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat!, lng!), zoom: 14)));
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
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  } //permission


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
          SizedBox(height: 10,),
          Container(

            child: FloatingActionButton(
              onPressed: () {
                filterMap();
              },
              child: IconButton(

                iconSize: 30,
                icon: Icon(Icons.layers) ,

                onPressed: (){showDropdownMenu(context);} ,

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
                  hintText: 'ابحث عن مطعم أو مكان سياحي',
                  hintStyle:
                  TextStyle(fontSize: 16, color: Color.fromARGB(255, 202, 198, 198)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  suffixIcon: _startSearchFieldController.text.isEmpty
                      ? Icon(Icons.search, color: Color.fromARGB(255, 109, 184, 129))
                      : IconButton(
                    icon: Icon(Icons.search, color: Color.fromARGB(255, 109, 184, 129)),
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
                    backgroundColor:  Color.fromARGB(255, 109, 184, 129),
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
                        _startSearchFieldController.text = details.result!.name!;
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
                new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer()),
              ].toSet(),
              mapType: MapType.normal,
              markers: markers.toSet(),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(target: currentLatLng, zoom: 14),
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
                'فئة المكان',
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


  void showDropdownMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' تصنيف المكان', style: TextStyle(color:  Color.fromARGB(255, 109, 184, 129),)),
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
                    'الكل',
                    'فعاليات و ترفيه',
                    'مطاعم',
                    'مراكز تسوق'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value, style: TextStyle(color:  Color.fromARGB(255, 109, 184, 129),)),
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
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
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
