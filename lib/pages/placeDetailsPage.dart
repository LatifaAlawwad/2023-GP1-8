import 'placePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:url_launcher/url_launcher.dart';
import 'HomePage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'dart:convert';




class placeDetailsPage extends StatefulWidget {
  final placePage place;

  placeDetailsPage({required this.place});

  @override
  State<placeDetailsPage> createState() => _placeDetailsState();
}

class _placeDetailsState extends State<placeDetailsPage> {

  String url = '';
  var data;
  List<dynamic> output = [];

  late String id;








  @override
  Widget build(BuildContext context) {

    String Category;
    String category = widget.place.category;

    if (category == 'أماكن سياحية') {
      Category = 'أماكن سياحية';
    } else if(category == 'مطاعم'){
      Category = 'مطاعم';
    }else {
      Category = 'مراكز التسوق';
    }

    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Hero(
              tag: '${widget.place.images.length}' == '0'
                  ? 'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'
                  : widget.place.images[0], //'${villa.images[0]}'
              child: Container(
                height: size.height * 0.5,
                decoration: '${widget.place.images.length}' == '0'
                    ? BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://www.guardanthealthamea.com/wp-content/uploads/2019/09/no-image.jpg'),
                  ),
                )
                    : BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        '${widget.place.images[0]}'), //'${villa.images[0]}'
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
            Container(
              height: size.height * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 228, 255, 226),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: const Color.fromARGB(255, 109, 184, 129),
                                size: 28,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,// it was MainAxisAlignment.spaceBetween
                      children: [

                        Text(
                          ' ${widget.place.placeName}',
                          style: TextStyle(
                            height: 2,
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal-m",
                          ),
                        )
                        ,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Align the content to the right
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                '${widget.place.neighbourhood} ، ${widget.place.city}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-m",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left:280,top:24,bottom: 16),
                          child: Text(
                            "التفاصيل",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tajawal-m",
                            ),
                          ),
                        ),
                        Padding(

                          padding: const EdgeInsets.only(right: 30, left: 27, bottom: 16),
                          child: Column(
                            children: [
                              Text(
                                '${widget.place.description}',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-l",
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 225, bottom: 16),
                          child: Text(
                            "المزيد من الصور",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tajawal-m",
                            ),
                          ),
                        ),

                        '${widget.place.images.length}' == '0'
                            ? Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Padding(
                              padding: EdgeInsets.only(left: 20, bottom: 24, right: 20),
                              child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    'لا توجد صور متاحة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Tajawal-l",
                                    ),
                                  ))),
                        )
                            : Directionality(
                          textDirection: TextDirection.rtl,
                          child: Container(
                            height: 200,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, bottom: 24, right: 20),
                              child: ListView.separated(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                // shrinkWrap: true,
                                separatorBuilder: (context, index) => SizedBox(width: 20),
                                itemCount: widget.place.images.length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () =>
                                      openGallery(widget.place.images, context),
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    widget.place.images[index],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 300, bottom: 16),
                              child: Text(
                                'الموقع',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal-m",
                                ),
                              ),
                            ),
                Padding(
                  padding: EdgeInsets.only(right: 33, left: 5, bottom: 16),
                  child: InkWell(
                    onTap: () {
                      String url = widget.place.Location; // Assuming `widget.place.Location` contains the link from the database
                      launch(url);
                    },
                    child: Text(
                      '${widget.place.Location}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Tajawal-l",
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),





                          ],
                        ),




                      ],
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
}

Widget PropInfo(IconData iconData, String text, String label) {
  return Column(
    children: [
      Icon(
        iconData,
        color: Color.fromARGB(255, 127, 166, 233),
        size: 28,
      ),
      SizedBox(
        height: 2,
      ),
      Text(
        label,
        style: TextStyle(
          color: Color.fromARGB(255, 127, 166, 233),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: "Tajawal-l",
        ),
      ),
      SizedBox(
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

openGallery(List images, BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
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
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
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