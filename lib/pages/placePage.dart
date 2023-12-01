class placePage {
  String place_id;
  String placeName;
  String userId;
  String category;
  String type1;
  String city;
  String neighbourhood;
  List<String> images;
  String description;
  String Location;
  bool allowChildren;
  double latitude;
  double longitude;
  List<Map<String, dynamic>> workedDays;
  bool hasValetServiced;
  List<String> cuisine;
  String priceRange;
  List<String>  serves;
  List<String> atmosphere;
  List<String> days;
  String openAt;
  String closeAt;
  bool hasCinema;
  bool INorOUT;
  bool hasFoodCourt;
  bool hasPlayArea;
  bool hasSupermarket;
  String startDate;
  String finishDate;
  String WebLink;
  bool hasReservation;
  String reservationDetails;
  List<String> shopOptions;
  bool isTemporary;

  placePage({
    required this.place_id,
    required this.placeName,
    required this.userId,
    required this.category,
    required this.type1,
    required this.city,
    required this.neighbourhood,
    required this.images,
    required this.description,
    required this.Location,
    required this.latitude,
    required this.longitude,
    this.workedDays=const[],
    this.allowChildren = false,
    this.hasValetServiced = false,
    this.cuisine = const [],
    this.priceRange = '',
    this.serves = const [],
    this.atmosphere = const [],
    this.days = const [],
    this.openAt = '',
    this.closeAt = '',
    this.hasCinema = false,
    this.INorOUT = false,
    this.hasFoodCourt = false,
    this.hasPlayArea = false,
    this.hasSupermarket = false,
    this.startDate = '',
    this.finishDate = '',
    this.WebLink = '',
    this.hasReservation=false,
    this.reservationDetails='',
    this.shopOptions = const [],
    this.isTemporary=false,

  });

  Map<String, dynamic> toMap() {
    return {
      'place_id': place_id,
      'userId': userId,
      'placeName': placeName,
      'category': category,
      'type1': type1,
      'city': city,
      'neighbourhood': neighbourhood,
      'images': images,
      'description': description,
      'Location': Location,
      'latitude': latitude,
      'longitude': longitude,
      'WorkedDays': workedDays,
      'hasValetServiced': hasValetServiced,
      'allowChildren': allowChildren,
      'cuisine': cuisine,
      'priceRange': priceRange,
      'serves': serves,
      'atmosphere': atmosphere,
      'days': days,
      'openAt': openAt,
      'closeAt': closeAt,
      'hasCinema': hasCinema,
      'INorOUT': INorOUT,
      'hasFoodCourt': hasFoodCourt,
      'hasPlayArea': hasPlayArea,
      'hasSupermarket': hasSupermarket,
      'startDate': startDate,
      'finishDate': finishDate,
      'WebLink': WebLink,
      'hasReservation':hasReservation,
      'reservationDetails':reservationDetails,
      'shopOptions': shopOptions,
      'isTemporary': isTemporary,
    };
  }

  factory placePage.fromMap(Map<String, dynamic> map) {
    return placePage(
      place_id: map['place_id'] ?? '',
      userId: map['userId'] ?? '',
      placeName: map['placeName'] ?? '',
      category: map['category'] ?? '',
      type1: map['type1'] ?? '',
      city: map['city'] ?? '',
      neighbourhood: map['neighbourhood'] ?? '',
      images: List<String>.from(map['images']??[]),
      description: map['description'] ?? '',
      Location: map['Location'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      workedDays: List<Map<String, dynamic>>.from(map['WorkedDays']??[]),
      hasValetServiced: map['hasValetServiced']?? false,
      allowChildren: map['allowChildren']?? false,
      cuisine:List<String>.from(map['cuisine']??[]),
      priceRange: map['priceRange']??'',
      serves: List<String>.from(map['serves']??[]),
      atmosphere: List<String>.from(map['atmosphere']??[]),
      days: List<String>.from(map['days']??[]),
      openAt: map['openAt']??'',
      closeAt: map['closeAt']??'',
      hasCinema: map['hasCinema']??false,
      INorOUT: map['INorOUT']??false,
      hasFoodCourt: map['hasFoodCourt']??false,
      hasPlayArea: map['hasPlayArea']??false,
      hasSupermarket: map['hasSupermarket']??false,
      startDate: map['startDate']??'',
      finishDate: map['finishDate']??'',
      WebLink: map['WebLink']??'',
      hasReservation: map['hasReservation']??false,
      reservationDetails: map['reservationDetails']??'',
      shopOptions: List<String>.from(map['shopOptions'] ?? []),
      isTemporary: map['isTemporary'] ?? false,
    );
  }

  // Getter methods
  String get getPlaceId => place_id;

  String get getPlaceName => placeName;

  String get getUserId => userId;

  String get getCategory => category;

  String get getType1 => type1;

  String get getCity => city;

  String get getNeighbourhood => neighbourhood;

  List<String> get getImages => images;

  String get getDescription => description;

  String get getLocation => Location;

  bool get getAllowChildren => allowChildren;

  double get getLatitude => latitude;

  double get getLongitude => longitude;

  List<Map<String, dynamic>> get getWorkedDays => workedDays;

  bool get getHasValetServiced => hasValetServiced;

  List<String> get getCuisine => cuisine;

  String get getPriceRange => priceRange;

  List<String> get getServes => serves;

  List<String> get getAtmosphere => atmosphere;

  List<String> get getDays => days;

  String get getOpenAt => openAt;

  String get getCloseAt => closeAt;

  bool get getHasCinema => hasCinema;

  bool get getINorOUT => INorOUT;

  bool get getHasFoodCourt => hasFoodCourt;

  bool get getHasPlayArea => hasPlayArea;

  bool get getHasSupermarket => hasSupermarket;

  String get getStartDate => startDate;

  String get getFinishDate => finishDate;

  String get getWebLink => WebLink;

  String get getReservationDetails => reservationDetails;

  bool get getHasReservation => hasReservation;

  List<String> get getShopOptions => shopOptions;

  bool get getisTemporary => isTemporary;

}