import 'package:flutter/material.dart';
import 'package:gp/helper/DayWidget.dart';
import 'package:gp/helper/showBoolAttributes.dart';
import 'package:gp/pages/placePage.dart';
import 'package:intl/intl.dart';
import 'package:gp/helper/ShowTextAttributesWidget.dart';
import 'ShowINorOUtAttributesWidget.dart';
import 'package:gp/language_constants.dart';


class PlaceDetailsWidget extends StatelessWidget {
  final placePage place;

  PlaceDetailsWidget({
    required this.place,
  });

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      DateTime date = DateTime.parse(dateString);
      String formattedDate = DateFormat('E d MMM hh:mm a').format(date);
      return formattedDate;
    } catch (e) {
      return null;
    }
  }







  List<String> originalAtmosphereOptions = [
    'يوجد موسيقى',
    'بدون موسيقى',
    'على البحر',
    'داخلي',
    'خارجي'
  ];
  List<String> EnglishAtmosphereOptions = [
    'music',
    'no music',
    'by the sea',
    'indoor',
    'outdoor'
  ];



  List<String> _generateAtmosphereOptions(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selectedOptions = place.atmosphere;
    final atmosphereOptions = isArabic ? originalAtmosphereOptions : EnglishAtmosphereOptions;

    return selectedOptions.map((option) {
      final index = originalAtmosphereOptions.indexOf(option);
      return index != -1 ? atmosphereOptions[index] : option;
    }).toList();
  }









  List<String> originalShopOptions = [
    'ملابس',
    'أحذية',
    'حقائب',
    'أثاث',
    'الكترونيات',
    'أواني',
    'عطور',
    'عبايات',
    'مجوهرات',
    'ملابس أطفال',
    'مستحضرات تجميل',
    'صيدليات',
    'أخرى'
  ];
  List<String> EnglishShopOptions = [
    "Clothing",
    "Shoes",
    "Bags",
    "Furniture",
    "Electronics",
    "Utensils",
    "Perfumes",
    "Abayas",
    "Jewelry",
    "Children's Clothing",
    "Cosmetics",
    "Pharmacies",
    "Other",
  ];



  List<String> _generateShopOptions(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selectedOptions = place.shopType;
    final shopeOptions = isArabic ? originalShopOptions : EnglishShopOptions;

    return selectedOptions.map((option) {
      final index = originalShopOptions.indexOf(option);
      return index != -1 ? shopeOptions[index] : option;
    }).toList();
  }




  String _generatePrice(BuildContext context) {
    final selectedOption = place.priceRange;

    // Define a map for translating price options
    final priceTranslations = {
      'مرتفع': translation(context).high,
      'متوسط': translation(context).medium,
      'منخفض': translation(context).low,
    };

    // Return the translated price based on the selected option
    return priceTranslations[selectedOption] ?? '';
  }





  String _generateFoodType(BuildContext context) {
    final selectedOptions = place.cuisine;

    // Check if selectedOptions is an array and get the first element
    final selectedOption = selectedOptions != null && selectedOptions.isNotEmpty
        ? selectedOptions[0]
        : null;


    final FoodTypeTranslations = {
      "سعودي": translation(context).saudi,
      "إيطالي": translation(context).italian,
      "أمريكي": translation(context).american,
      "آسيوي": translation(context).asian,
      "هندي": translation(context).indian,
      "مكسيكي": translation(context).mexican,
      "تركي": translation(context).turkish,
      "بحري": translation(context).seafood,
      "إسباني": translation(context).spanish,
      "شرقي": translation(context).middle_eastern,
      "يوناني": translation(context).greek,
      "مخبوزات": translation(context).bakery,
      "عالمي": translation(context).international,
      "صحي": translation(context).healthy,
      "قهوة وحلى": translation(context).coffee_and_desserts,
    };

    // Return the translated price based on the selected option
    return selectedOption != null
        ? FoodTypeTranslations[selectedOption] ?? ''
        : '';
  }








  Widget _buildCard(String value) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF6db881),
          width: 1,
        ),
      ),
      child: Text(value),
    );
  }
  Widget _buildTextCard(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF6db881),
          width: 1,
        ),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(place.toMap().toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Divider(),
        if (place.WebLink != '')
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 5,
              ),
             Text(
                translation(context).webLINK,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Tajawal-m",
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                '${place.WebLink}',
                textAlign: TextAlign.right,
              ),
            ],
          ),

        if (place.category == 'مطاعم') ...[
          Divider(),
          if (place.cuisine.length > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  translation(context).foodTypee,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                _buildTextCard(_generateFoodType(context)),
              ],
            ),
          if (place.priceRange != '')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Text(
                      translation(context).priceRangee,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Tajawal-m",
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(width: 4),
                    _buildTextCard(_generatePrice(context)),
                  ],
                ),
              ],
            ),


          if (place.atmosphere.length > 0) ...[
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
               translation(context).atmospheree,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 3,
                  children: _generateAtmosphereOptions(context).map((e) => _buildCard(e)).toList(),
                )
              ],
            ),
          ],
        ],


        if (place.category == 'مراكز تسوق')

          Wrap(alignment: WrapAlignment.end, spacing: 3, children: [
            const SizedBox(
              height: 4,
            ),
            Divider(),
            if (place.shopType.length > 0) ...[
              const SizedBox(
                height: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    translation(context).storeTypee,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Tajawal-m",
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 3,
                    children: _generateShopOptions(context).map((e) => _buildCard(e)).toList(),
                  )
                ],
              ),
            ],
            Divider(),
            ShowBoolAttributesWidget(text: translation(context).cinema, check: place.hasCinema),
            ShowBoolAttributesWidget(
                text:translation(context).restaurant_area, check: place.hasFoodCourt),
            ShowINorOUtAttributesWidget(
              text: place.INorOUT == 'كلاهما'
                  ? translation(context).inANDout
                  : place.INorOUT == 'نعم'
                  ? translation(context).outdoor
                  : translation(context).indoor,

            ),

            ShowBoolAttributesWidget(
                text: translation(context).play_area, check: place.hasPlayArea),
            ShowBoolAttributesWidget(
                text: translation(context).supermarket, check: place.hasSupermarket),
            ShowBoolAttributesWidget(
                text: translation(context).valet, check: place.hasValetServiced),


          ]),

        Divider(),
        if (place.category == 'مطاعم') ...[
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 3, // Adjust the spacing between widgets
            children: [
              ShowBoolAttributesWidget(
                text: translation(context).allowCHI,
                check: place.allowChildren,
              ),
              ShowBoolAttributesWidget(
                text: translation(context).needBooking,
                check: place.hasReservation,
              ),

              ShowBoolAttributesWidget(
                  text: translation(context).valet, check: place.hasValetServiced),
            ],
          ),
          Divider(),
          if (place.hasReservation)
            ShowTextAttributesWidget(
              text: place.reservationDetails,
            ),
        ],

        if (place.category == 'فعاليات و ترفيه') ...[
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,

            children: [
              ShowBoolAttributesWidget(
                text: translation(context).needBooking,
                check: place.hasReservation,
              ),
              ShowBoolAttributesWidget(
                  text: translation(context).valet, check: place.hasValetServiced),

              ShowINorOUtAttributesWidget(
                text: place.INorOUT == 'كلاهما'
                    ? translation(context).inANDout
                    : place.INorOUT == 'نعم'
                    ? translation(context).outdoor
                    : translation(context).indoor,

              ),
              ShowBoolAttributesWidget(
                text: translation(context).tempENt,
                check: place.isTemporary,
              ),


          ]
          ),
          Divider(),
          if (place.hasReservation) // Check if hasReservation is true
            ShowTextAttributesWidget(
              text: place.reservationDetails,

            ),

          const SizedBox(
            height: 4,
          ),

          if (place.startDate != '') ...[
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${formatDate(place.startDate)}',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
               Text(
                 translation(context).startdate,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                ),
              ],
            ),
          ],
          if (place.finishDate != '') ...[
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${formatDate(place.finishDate)}',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 4,
                ),
             Text(
               translation(context).enddate,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal-m",
                  ),
                ),
              ],
            ),
          ]
        ],
        if (place.workedDays.length > 0)
          PlaceDays(
            place: place,
          )
      ],
    );
  }

}
