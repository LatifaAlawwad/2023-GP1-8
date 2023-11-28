class Geometry {
  late LocationLatLng location;

  Geometry({required this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: LocationLatLng.fromJson(json['location']),
    );
  }
}

class LocationLatLng {
  late double lat;
  late double lng;

  LocationLatLng({required this.lat, required this.lng});

  factory LocationLatLng.fromJson(Map<String, dynamic> json) {
    return LocationLatLng(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class PinDropLocation {
  late Geometry geometry;
  late String name;

  PinDropLocation({required this.geometry, required this.name});

  factory PinDropLocation.fromJson(Map<String, dynamic> json) {
    return PinDropLocation(
      geometry: Geometry.fromJson(json['geometry']),
      name: json['name'],
    );
  }
}