import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gp/helper/convertLocationJson.dart';
import 'package:gp/language_constants.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng startLocation = LatLng(24.7136, 46.6753); // Riyadh, Saudi Arabia
  String googleApikey = "AIzaSyCJ3yUvAXaEKXPoo5ngfht4se568rq3mBk";
  GoogleMapController? mapController; //contrller for Google map
  CameraPosition? cameraPosition;
  String location ="";

  @override
  Widget build(BuildContext context) {
    location = translation(context).locatioName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation(context).addMap,
        ),
        backgroundColor: const Color.fromARGB(255, 109, 184, 129),
        centerTitle: true,),
      body: Stack(children: [
        GoogleMap(
          //Map widget from google_maps_flutter package
          zoomGesturesEnabled: true,
          //enable Zoom in, out on map
          initialCameraPosition: CameraPosition(
            //innital position in map
            target: startLocation, //initial position
            zoom: 10.0, //initial zoom level
          ),
          mapType: MapType.normal,
          //map type
          onMapCreated: (controller) {
            //method called when map is created
            setState(() {
              mapController = controller;
            });
          },
          onCameraMove: (CameraPosition cameraPositiona) {
            cameraPosition = cameraPositiona; //when map is dragging
          },
          onCameraIdle: () async {
            //when map drag stops
            List<Placemark> placemarks = await placemarkFromCoordinates(
                cameraPosition!.target.latitude,
                cameraPosition!.target.longitude);
            setState(() {
              //get place name from lat and lang
              print(cameraPosition);
              location = placemarks.first.administrativeArea.toString() +
                  ", " +
                  placemarks.first.street.toString();
            });
          },
        ),
        Center(
            //picker image on google map
            child: Icon(
          Icons.location_on,
          color: Colors.red,
        )),
        Positioned(
            //widget to display location name
            bottom: 100,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width - 40,
                        child: ListTile(
                          title: Text(
                            location,
                            style: TextStyle(fontSize: 18),
                          ),
                          dense: true,
                        )),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(
                            context,
                            PinDropLocation(
                                geometry: Geometry(
                                    location: LocationLatLng(
                                        lat: cameraPosition!.target.latitude,
                                        lng: cameraPosition!.target.longitude)),
                                name: location));
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xFF6db881)),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child:  Text(
                        translation(context).save,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: "Tajawal-m",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ]),
    );
  }
}
