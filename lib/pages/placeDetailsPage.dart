import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gp/helper/PlaceDetailsWidget.dart';
import 'package:uuid/uuid.dart';
import '../Registration/logIn.dart';
import 'placePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HomePage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'Review.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class placeDetailsPage extends StatefulWidget {
  final placePage place;

  placeDetailsPage({required this.place});

  @override
  State<placeDetailsPage> createState() => _placeDetailsState();
}

class _placeDetailsState extends State<placeDetailsPage> {

  late GoogleMapController myMapController;
  final Set<Marker> _markers = new Set();

  Set<Marker> myMarker() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(
            LatLng(widget.place.latitude, widget.place.longitude).toString()),
        position: LatLng(widget.place.latitude, widget.place.longitude),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });

    return _markers;
  }

  String url = '';
  var data;
  List<dynamic> output = [];
  late String id;
  final ScrollController _scrollController = ScrollController();
  double thumbWidth = 0.0;
  double thumbPosition = 0.0;
  final _formKey = GlobalKey<FormState>();

//final ReviewService _reviewService = ReviewService();
  List<Review> reviews = [];

  @override
  void initState() {
    widget.place.toMap().forEach((key, value) {
      print(key + " : " + value.toString());
    });
    super.initState();

    _scrollController.addListener(() {
      double scrollPosition = _scrollController.position.pixels;
      double maxScrollExtent = _scrollController.position.maxScrollExtent;

      setState(() {
        thumbWidth = (scrollPosition / maxScrollExtent) *
            _scrollController.position.viewportDimension;
        thumbPosition = (scrollPosition / maxScrollExtent) *
            (_scrollController.position.viewportDimension - thumbWidth);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String Category;
    String category = widget.place.category;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (category == 'فعاليات و ترفيه') {
      Category = 'فعاليات و ترفيه';
    } else if (category == 'مطاعم') {
      Category = 'مطاعم';
    } else {
      Category = 'مراكز التسوق';
    }

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Hero(
              tag: '${widget.place.images.length}' == '0'
                  ? 'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'
                  : widget.place.images[0],
              child: Container(
                height: size.height * 0.4,
                decoration: '${widget.place.images.length}' == '0'
                    ? const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'),
                  ),
                )
                    : BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('${widget.place.images[0]}'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6db881),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ' ${widget.place.placeName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.place.neighbourhood} ، ${widget.place.city}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-l",
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Icon(
                          Icons.location_pin,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ApprovedPlaces')
                          .doc(widget.place.place_id)
                          .collection('Reviews')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        List<double> ratings = List<double>.from(
                          snapshot.data!.docs.map((doc) {
                            final commentData =
                            doc.data() as Map<String, dynamic>;
                            return commentData["rating"].toDouble() ?? 0.0;
                          }),
                        );

                        // Calculate the average rating
                        double averageRating = ratings.isNotEmpty
                            ? ratings.reduce((a, b) => a + b) / ratings.length
                            : 0.0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (int index = 0; index < 5; index++)
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Icon(
                                  index < averageRating.floor()
                                      ? Icons.star
                                      : index + 0.5 == averageRating
                                      ? Icons.star_half
                                      : Icons.star_border,
                                  color:
                                  const Color.fromARGB(255, 109, 184, 129),
                                  size: 22.0,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
    child: ScrollbarTheme(
    data: ScrollbarThemeData(
    thumbColor: MaterialStateProperty.all(Color.fromARGB(
    255, 109, 184, 129), )// Set the color of the scrollbar thumb
    //  trackColor: MaterialStateProperty.all( Color.fromARGB(255, 17, 99, 14)),// Set the color of the track
    ),
    child: Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "الوصف",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${widget.place.description}',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-l",
                          ),
                        ),
                        const SizedBox(height: 10),
                        PlaceDetailsWidget(place: widget.place),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "المزيد من الصور",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-m",
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        widget.place.images.length == 0
                            ? Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, bottom: 24, right: 20),
                              child: Text(
                                'لا توجد صور متاحة',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-l",
                                ),
                              )),
                        )
                            : Directionality(
                          textDirection: TextDirection.rtl,
                          child: SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                RawScrollbar(
                                  thumbColor: const Color.fromARGB(
                                      255, 17, 99, 14),
                                  radius: const Radius.circular(20),
                                  thickness: 5,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    // Always show the scrollbar
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      physics:
                                      const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                      widget.place.images.length,
                                      itemBuilder: (context, index) =>
                                          InkWell(
                                            onTap: () => openGallery(
                                                widget.place.images, context),
                                            borderRadius:
                                            BorderRadius.circular(15),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(2),
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(15),
                                                child: Image.network(
                                                  widget.place.images[index],
                                                ),
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (widget.place.latitude != 0 &&
                            widget.place.longitude != 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'الموقع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-m",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black54,
                                      width: 1,
                                    ),
                                  ),
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(widget.place.latitude,
                                            widget.place.longitude),
                                        zoom: 10.0,
                                      ),
                                      markers: this.myMarker(),
                                      mapType: MapType.normal,
                                      onMapCreated: (controller) {
                                        setState(() {
                                          myMapController = controller;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        Divider(),


                        FutureBuilder<String>(
                          future: checkPlaceStatus(widget.place.place_id),
                          builder: (context, snapshot) {
                            print('Snapshot Data: ${snapshot.data}');
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data == "yes" ) {
                              print('Hiding content because snapshot data is "yes"');
                             return Container();
                                } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,

                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (currentUser == null) {
                                              showguestDialog(context);
                                            } else {
                                              // Check if the user has already submitted a review
                                              bool hasPreviousReview = await checkPreviousReview(widget.place.place_id);

                                              if (hasPreviousReview) {
                                                // User has a previous review, show a message indicating they can update
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'لديك تقييم وتعليق سابق، يمكنك تحديثه من قسم التعليقات.',
                                                    ),
                                                    duration: Duration(seconds: 5),
                                                  ),
                                                );
                                              } else {
                                                // User does not have a previous review, open the review dialog
                                                showReviewDialog(context, widget.place.place_id);
                                              }
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.white),
                                            side: MaterialStateProperty.all(
                                              const BorderSide(color: Color(0xFF6db881), width: 1.0),
                                            ),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'قيّم وشارك تجربتك',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "Tajawal-m",
                                              color: Color(0xFF6db881),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        ':التعليقات',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Tajawal-m",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('ApprovedPlaces')
                                        .doc(widget.place.place_id)
                                        .collection('Reviews')
                                        .orderBy('timestamp', descending: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                                            child: Text(
                                              'لا يوجد أي تعليق حتى الان ',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "Tajawal-m",
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      // Retrieve reviews from the snapshot
                                      List<Review> reviews = snapshot.data!.docs.map((doc) {
                                        final commentData = doc.data() as Map<String, dynamic>;
                                        return Review(
                                          id: commentData["id"] ?? "",
                                          placeId: commentData["placeId"] ?? "",
                                          userId: commentData["userId"] ?? "",
                                          userName: commentData["userName"] ?? "anonymous",
                                          rating: commentData["rating"].toDouble() ?? 0.0,
                                          text: commentData["text"] ?? "",
                                          timestamp: formatDate(commentData["timestamp"]),
                                          currentUserReview: commentData["userId"] == getuserId(),
                                          onDelete: () async {
                                            // Handle delete action
                                            await deleteReview(
                                              context, // Pass the BuildContext
                                              commentData["placeId"] ?? "", // Pass placeId
                                              doc.id, // Pass reviewId
                                            );
                                            // Pass placeId
                                            // Optionally, you can perform additional actions after deletion
                                          },
                                          onUpdate: () {
                                            // Show a dialog to enter the updated comment
                                            showReviewDialog(
                                              context,
                                              widget.place.place_id,
                                              initialRating: commentData["rating"].toDouble(),
                                              initialComment: commentData["text"],
                                            );
                                          },
                                        );
                                      }).toList();

                                      // Sort the reviews to have the user's review first
                                      reviews.sort((a, b) {
                                        if (a.currentUserReview) {
                                          return -1; // User's review comes first
                                        } else if (b.currentUserReview) {
                                          return 1;
                                        } else {
                                          return b.timestamp.compareTo(a.timestamp);
                                        }
                                      });

                                      return ListView(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: reviews,
                                      );
                                    },
                                  ),
                                ],
                                );
                            }
                          },
                        )













                      ],
                    ),
                  ),
                ),
    ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }





  Future<String> checkPlaceStatus(String placeId) async {
    try {
      DocumentSnapshot snapshotPending = await FirebaseFirestore.instance
          .collection('PendingPlaces')
          .doc(placeId)
          .get();

      QuerySnapshot snapshotRejected = await FirebaseFirestore.instance
          .collection('RejectedPlaces')
          .where('place_id', isEqualTo: placeId)
          .get();

print(placeId);
      if (snapshotRejected.docs.isNotEmpty  || snapshotPending.exists) {
        return "yes";
      }

      // If the document is not found in the "RejectedPlaces" collection, return an empty string or null
      return "";
    } catch (e) {
      print("Error checking place status: $e");
      return ""; // Return an empty string or null in case of an error
    }
  }














  Future<bool> checkPreviousReview(String placeId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String userId = user?.uid ?? '';

    if (userId.isNotEmpty) {
      // Check if the user has a previous review for the given placeId
      QuerySnapshot existingReviews = await FirebaseFirestore.instance
          .collection('ApprovedPlaces')
          .doc(placeId)
          .collection('Reviews')
          .where('userId', isEqualTo: userId)
          .get();

      return existingReviews.docs.isNotEmpty;
    }

    return false;
  }

  String formatDate(Timestamp time) {
    DateTime datatime = time.toDate();
    String year = datatime.year.toString();
    String month = datatime.month.toString();
    String day = datatime.day.toString();
    String formattedData = '$day/$month/$year';
    return formattedData;
  }

  String getuserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var cpuid = user!.uid;
    return cpuid;
  }

  void showReviewDialog(BuildContext context, String placeId,
      {double initialRating = 0.0, String initialComment = ''}) async {
    double rating = initialRating; // Variable to store the user's rating
    String reviewText = initialComment; // Variable to store the user's review
    String userId = getuserId();
    String username;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot =
    await firestore.collection('users').doc(userId).get();
    if (documentSnapshot.exists) {
      username = documentSnapshot
          .get('name'); // Replace 'name' with the actual field name
    } else {
      username = "anonymous";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          contentPadding: const EdgeInsets.only(top: 10.0),
          content: SizedBox(
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Center(
                  child: Text(
                    "شارك تجربتك",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: "Tajawal-m",
                    ),
                    textDirection: TextDirection.rtl,
                    // Right-to-left text direction
                  ),
                ),
                const SizedBox(height: 20.0),
                // Rating Bar and Text
                SizedBox(
                  height: 50.0,
                  // Set the desired height for the RatingBar and text
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RatingBar.builder(
                        initialRating: initialRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 30.0,
                        itemPadding:
                        const EdgeInsets.symmetric(horizontal: 4.0),
                        unratedColor: const Color.fromARGB(255, 109, 184, 129),
                        itemBuilder: (context, index) {
                          if (index < rating) {
                            return const Icon(
                              Icons.star,
                              color: Color.fromARGB(255, 109, 184, 129),
                              // Filled star
                              size: 30.0,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Color.fromARGB(255, 109, 184, 129),
                              // Outlined star with the same color
                              size: 30.0,
                            );
                          }
                        },
                        onRatingUpdate: (newRating) {
                          rating = newRating;
                        },
                      ),
                      const SizedBox(width: 1.0),
                      // Add spacing between the RatingBar and the text
                      const Text(
                        "قيّم تجربتك",
                        style: TextStyle(
                          fontFamily: "Tajawal-m",
                        ),
                      ),
                    ],
                  ),
                ),
                // Text Field with Top Border and Radius
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      const BoxShadow(
                        blurRadius: 5.0,
                        offset: Offset(0, -1),
                        color: Colors.grey,
                      ),
                    ],
                    border: Border.all(
                      color: const Color.fromARGB(255, 109, 184, 129),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextField(
                      onChanged: (text) {
                        reviewText = text;
                      },
                      controller: TextEditingController(text: initialComment),
                      decoration: const InputDecoration(
                        hintText: 'اكتب تعليقك هنا...',
                        hintStyle: TextStyle(
                          fontFamily: "Tajawal-m",
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: 8,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                // Submit and Cancel Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          padding:
                          const EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 109, 184, 129),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                            ),
                          ),
                          child: const Text(
                            "ارسال",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Tajawal-m"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () async {
                          // Save the review and rating to the Firestore collection
                          if (reviewText == '' && rating == 0.0) {
                            // do nothing, don't save it in the collection
                          } else {
                            await makePostRequest(
                                reviewText, rating, userId, placeId, username);
                          }

                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    // Adjust the height to change the length
                    const VerticalDivider(
                      width: 1, // Width of the vertical line
                      color: Colors.white, // Color of the vertical line
                    ),

                    Expanded(
                      child: InkWell(
                        child: Container(
                          padding:
                          const EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 109, 184, 129),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(32.0),
                            ),
                          ),
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Tajawal-m"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          // Close the dialog without saving
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

















////////////////////////////////////////////////////////////////////////////////////
  Future<void> deleteReview(BuildContext context, String placeId, String reviewId) async {
    try {
      // Implement the logic to delete the review from Firebase
      await FirebaseFirestore.instance
          .collection('ApprovedPlaces')
          .doc(placeId)
          .collection('Reviews')
          .doc(reviewId)
          .delete();

      // Show a toast message to indicate successful deletion
      Fluttertoast.showToast(
        msg: 'تم حذف التقييم بنجاح',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 109, 184, 129),

      );

      // Optionally, you can perform additional actions after deletion
    } catch (error) {
      // Handle errors if any
      print('Error deleting review: $error');

      // Show an error toast message
      Fluttertoast.showToast(
        msg: 'يوجد هناك مشكلة في حذف التقييم حاول مرة أخرى',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 109, 184, 129)

      );
    }
  }

  Future<void> updateReviewText(
      String placeId, String reviewId, String newReviewText) async {
    // Update the review text in Firebase
    await FirebaseFirestore.instance
        .collection('ApprovedPlaces')
        .doc(placeId)
        .collection('Reviews')
        .doc(reviewId)
        .update({
      'text': newReviewText,
    });
  }
}
////////////////////////////////////////////////////////////////////////////////////
Future<void> makePostRequest(String reviewText, double rating, String userId, String placeid, String username) async {
  try {
    // Detect the language of the review text
    String language = detectLanguage(string: reviewText);

    // Make the profanity filter API request
    final uri = Uri.parse('https://profanity-cleaner-bad-word-filter.p.rapidapi.com/profanity');
    final headers = {
      'Content-Type': 'application/json',
      'X-RapidAPI-Key': 'f3c39b2fbamsh9dd5600086c2bd6p11cd83jsn3b07a4b3724c',
    };

    Map<String, dynamic> body = {
      'text': reviewText,
      'maskCharacter': '*',
      'language': language,
    };

    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    var response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    Map responseBody = jsonDecode(response.body);
    print(responseBody['clean']);

    // Save the cleaned review to Firebase Firestore
    await _saveReviewToFirebase(responseBody['clean'], rating, userId, placeid, username);
  } catch (error) {
    // Handle errors during the process
    print('Error making POST request: $error');
  }
}
String detectLanguage({required String string}) {
  String languageCode = 'ar'; // Default to Arabic

  final RegExp english = RegExp(r'^[a-zA-Z]+');
  final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');

  if (english.hasMatch(string)) {
    languageCode = 'en'; // Set to English if the string contains English characters
  } else if (arabic.hasMatch(string)) {
    languageCode = 'ar'; // Set to Arabic if the string contains Arabic characters
  }

  return languageCode;
}

Future<void> _saveReviewToFirebase(String reviewText, double rating, String userId, String placeId, String username, [String? reviewId]) async {
  final CollectionReference reviewsCollection = FirebaseFirestore.instance.collection('ApprovedPlaces').doc(placeId).collection('Reviews');

  // Check for previous reviews with the same userId for the specific place
  QuerySnapshot existingReviews = await reviewsCollection.where('userId', isEqualTo: userId).get();

  // Exclude the current review from the check if the user is updating the comment
  if (existingReviews.docs.isNotEmpty && (reviewText.isNotEmpty || rating > 0.0)) {
    // User has already submitted a review for this place, allow updating the comment, rating, and timestamp
    var existingReview = existingReviews.docs.first;
    await existingReview.reference.update({
      'text': reviewText.isNotEmpty ? reviewText : existingReview['text'],
      'rating': rating > 0.0 ? rating : existingReview['rating'],
      'timestamp': Timestamp.now(),
    });

    // Display a success message or perform additional actions if needed
    Fluttertoast.showToast(
      msg: 'تم تحديث التقييم بنجاح',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(0xFF6db881),
      textColor: Colors.white,
    );
  } else {
    // User does not have a previous review and rate, proceed to save the new review and rate
    var uuid = Uuid();
    String newReviewId = uuid.v4();

    // Create a new review document with a timestamp
    await reviewsCollection.add({
      'id': newReviewId,
      'placeId': placeId,
      'userId': userId,
      'userName': username,
      'text': reviewText,
      'rating': rating,
      'timestamp': Timestamp.now(), // Firestore server timestamp
    }).then((value) {
      // Display a success message or perform additional actions if needed
      Fluttertoast.showToast(
        msg: 'تم إضافة التقييم بنجاح',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xFF6db881),
        textColor: Colors.white,
      );
    }).catchError((error) {
      // Handle any errors that occur
      print('Error saving review: $error');
    });
  }
}


List<String> detectLanguages({required String string}) {
  List<String> languageCodes = [];

  final RegExp english = RegExp(r'^[a-zA-Z]+');
  final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');

  // Split the input string into words
  List<String> words = string.split(' ');

  // Check the language of each word
  for (String word in words) {
    if (english.hasMatch(word)) {
      languageCodes.add('en'); // Set to English if the word contains English characters
    } else if (arabic.hasMatch(word)) {
      languageCodes.add('ar'); // Set to Arabic if the word contains Arabic characters
    }
  }

  // Remove duplicate language codes
  languageCodes = languageCodes.toSet().toList();

  // If no language is detected, default to Arabic
  if (languageCodes.isEmpty) {
    languageCodes.add('ar');
  }

  return languageCodes;
}


showguestDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        contentPadding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        content: SizedBox(
          width: 300.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 79),
                      child: Text(
                        "عذراً لابد من تسجيل الدخول",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Tajawal-b",
                          color: Color(0xFF6db881),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogIn()),
                        );
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
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                      ),
                      child: const Text(
                        "تسجيل الدخول",
                        style: TextStyle(fontSize: 20, fontFamily: "Tajawal-m"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

double calculateAverageRating(List<Review> reviews) {
  if (reviews.isEmpty) {
    return 0.0; // Default rating if there are no reviews
  }

  double totalRating = 0.0;
  for (Review review in reviews) {
    totalRating += review.rating;
  }

  return totalRating / reviews.length;
}














Widget PlaceInfo(IconData iconData, String text, String label) {
  return Column(
    children: [
      Icon(
        iconData,
        color: const Color.fromARGB(255, 109, 184, 129),
        size: 28,
      ),
      const SizedBox(
        height: 2,
      ),
      Text(
        label,
        style: const TextStyle(
          color: Color.fromARGB(255, 109, 184, 129),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: "Tajawal-l",
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      Text(
        text,
        style: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
          fontFamily: "Tajawal-l",
          fontSize: 14,
        ),
      ),
    ],
  );
}

openGallery(List images, BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GalleryWidget(
        images: images,
      ),
    ));

class GalleryWidget extends StatefulWidget {
  final List<dynamic> images;

  GalleryWidget({
    required this.images,
  });

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        body: PhotoViewGallery.builder(
          itemCount: widget.images.length,
          builder: (context, index) {
            final image = widget.images[index];

            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(image),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
            );
          },
        ),
      ),
    );
  }
}