import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gp/helper/CustomRadioButton.dart';
import 'package:shared_preferences/shared_preferences.dart';





class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage>  {





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 109, 184, 129),
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 150),
          child: Text(
            "تصفية",
            style: TextStyle(
              fontSize: 22,
              fontFamily: "Tajawal-b",
            ),
          ),
        ),
        toolbarHeight: 60,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                CustomFormState().resetFilterState;

                Navigator.pop(context, null);
              },
              child: Container(
                padding: const EdgeInsets.only(right:9.0),
                child: const Icon(
                  Icons.close_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xff6db881),
                ),
              ),
            ],
          ),
          CustomForm(),
        ],
      ),
    );
  }
}













class CustomForm extends StatefulWidget {
  const CustomForm({Key? key});

  @override
  CustomFormState createState() {
    return CustomFormState();
  }
}





class CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
   int type = 0;
  String? type1;

  late SharedPreferences prefs;









  List<String> userChecked = [];
  List<String> cuisine = [];
  List<String> cuisineOptions = [
    'سعودي',
    'إيطالي',
    'أمريكي',
    'آسيوي',
    'هندي',
    'مكسيكي',
    'تركي',
    ' بحري',
    'إسباني',
    'شرقي',
    'يوناني',
    'مخبوزات',
    'عالمي',
    'صحي',
  ];

  List<bool> checkedOptionsatt = [false, false, false,false,false,false,false];
  List<bool> checkedOptionsmalls = [false, false, false,false];
  List<bool> checkedOptionsres = [false, false, false,false,false,false,false,false,false,false,false,false,false,false];


  List<bool> ocheckedOptionsatt = [false, false, false,false,false,false,false];
  List<bool> ocheckedOptionsmalls = [false, false, false,false];
  List<bool> ocheckedOptionsres = [false, false, false,false,false,false,false,false,false,false,false,false,false,false];

  List<String> isThereInMalls=['سينما','منطقة ألعاب','منطقة مطاعم','سوبرماركت']  ;
  List<String> typeEntOptions = [
    'رياضة و مغامرات',
    'فنون',
    'معالم تاريخية',
    'ثقافة',
    'حدائق و منتزهات',
    'مدينة  ملاهي',
    'معارض',
  ];



  List<String> shopOptions = [
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
  Set<String> serves = Set<String>();
  Set<String> price = Set<String>();
  Set<String> atmosphere = Set<String>();
  Set<String> shopType = Set<String>();
  String INorOUT='';
  bool? hasReservation;

  String typeEnt='';
  String cus='';



  List<String> servesOptions = ['فطور', 'غداء', 'عشاء'];
  List<String> priceRange = ['مرتفع','متوسط','منخفض'];


  List<String> atmosphereOptions = [
    'يوجد موسيقى',
    'بدون موسيقى',
    'على البحر',
    'داخلي',
    'خارجي'
  ];

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

  List<String> originalAtmosphereOptions = [
    'يوجد موسيقى',
    'بدون موسيقى',
    'على البحر',
    'داخلي',
    'خارجي'
  ];


  List<String> originalServesOptions = ['فطور', 'غداء', 'عشاء'];
  bool? originalHasReservation;
String originalINorOUT='';





  List<String> originalIsThereInMalls =['سينما','منطقة ألعاب','منطقة مطاعم','سوبرماركت'] ;




  List<String> originalPriceRange = ['مرتفع','متوسط','منخفض'];


void initState() {
    super.initState();

    initPrefs();


    originalINorOUT = INorOUT;
    originalHasReservation = hasReservation;
    originalIsThereInMalls = List.from(isThereInMalls);
    originalPriceRange = List<String>.from(priceRange);
    originalServesOptions = List.from(servesOptions);
    originalAtmosphereOptions = List.from(atmosphereOptions);
    originalShopOptions = List.from(shopOptions);


  }







  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    loadFilterState();
  }



  void saveFilterState() {

    prefs.setInt('type', type);


      switch (type) {

        case 0 :
        case 1:// فعاليات و ترفيه
        prefs.setStringList('checkedOptionsatt', checkedOptionsatt.map((value) => value.toString()).toList());
        if (INorOUT != '') {
          prefs.setString('INorOUT', INorOUT!);
        } else {
          prefs.remove('INorOUT'); // Remove the key if INorOUT is null
        }
        if (hasReservation != null) {
          prefs.setBool('hasReservation', hasReservation!);
        } else {
          prefs.remove('hasReservation'); // Remove the key if hasReservation is null
        }

        break;
        case 0 :
      case 2: // مطاعم
        prefs.setStringList('checkedOptionsres', checkedOptionsres.map((value) => value.toString()).toList());
        prefs.setStringList('price', price.toList());
        prefs.setStringList('serves', serves.toList());
        prefs.setStringList('atmosphere', atmosphere.toList());
        prefs.setBool('hasReservationSet', hasReservation != null);
        if (hasReservation != null) {
          prefs.setBool('hasReservation', hasReservation!);
        } else {
          prefs.remove('hasReservation'); // Remove the key if hasReservation is null
        }



        break;
     case 0 :
      case 3: // المراكز التجارية
        if (INorOUT != '') {
          prefs.setString('INorOUT', INorOUT!);
        } else {
          prefs.remove('INorOUT'); // Remove the key if INorOUT is null
        }

        prefs.setStringList('checkedOptionsmalls', checkedOptionsmalls.map((value) => value.toString()).toList());
        prefs.setStringList('shopType', shopType.map((e) => e.toString()).toList());


        break;





    }
  }






  void loadFilterState() {

    setState(() {
    int savedType = prefs.getInt('type') ?? 0;
    type = savedType;



      switch (type) {

        case 0: type=0;
            break;

        case 1:// فعاليات و ترفيه


          checkedOptionsatt = prefs.getStringList('checkedOptionsatt')?.map((value) => value == 'true').toList() ?? [];
          INorOUT = prefs.getString('INorOUT') ?? ''; // Nullable bool
          hasReservation = prefs.getBool('hasReservation') ?? null; // Nullable bool
          break;

        case 2: // مطاعم
          checkedOptionsres = prefs.getStringList('checkedOptionsres')?.map((value) => value == 'true').toList() ?? [];
          price = prefs.getStringList('price')?.toSet() ?? Set<String>();
          serves = prefs.getStringList('serves')?.toSet() ?? Set<String>();
          atmosphere = prefs.getStringList('atmosphere')?.toSet() ?? Set<String>();
          hasReservation = prefs.getBool('hasReservation') ?? null; // Nullable bool
          break;

        case 3: // المراكز التجارية
          INorOUT = prefs.getString('INorOUT') ?? '';
          checkedOptionsmalls = prefs.getStringList('checkedOptionsmalls')?.map((value) => value == 'true').toList() ?? [];
          shopType = prefs.getStringList('shopType')?.toSet() ?? Set<String>();
          break;


      }
    });
  }







 void resetFilterState() {
    setState(() {
      switch (type) {
        case 1:

          checkedOptionsatt = List.from(ocheckedOptionsatt);
          INorOUT = originalINorOUT;
          hasReservation = originalHasReservation;
          break;
        case 2:
          checkedOptionsres = List.from(ocheckedOptionsres);
          serves.clear();
          price.clear();
          atmosphere.clear();
          hasReservation = originalHasReservation;
          break;
        case 3:
          INorOUT = originalINorOUT;
          isThereInMalls = List.from(originalIsThereInMalls);
          checkedOptionsmalls = List.from(ocheckedOptionsmalls);
          shopType.clear();
          break;
      }

      type=0;
      saveFilterState();

    });

  }




















  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [



                  const SizedBox(
                    height: 20,
                  ),


                  const Text(
                    ':تصنيف المكان ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Tajawal-b",
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    // Adjust top and left values
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: null, // Set initial value to null
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6db881),
                        ),
                        contentPadding: EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
                      ),
                      iconSize: 0,
                      hint: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اختر تصنيف المكان',
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "فعاليات و ترفيه",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "مطاعم",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "مراكز تسوق",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          type = value!;
                          if (type == 1) type1 = 'فعاليات و ترفيه';
                          if (type == 2) type1 = 'مطاعم';
                          if (type == 3) type1 = 'مراكز تسوق';
                        });
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),




                  /////////////////////////////////new attr////////////////////////////////////////////////

                  if (type == 1)
                  Column(



                    mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        const SizedBox(height: 10),
                        const Text(
                          'نوع الفعالية',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: typeEntOptions.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    typeEntOptions[index],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Tajawal-m",
                                      color: Color(0xFF6db881),
                                    ),
                                  ),
                                ),
                                activeColor: const Color.fromARGB(
                                    255, 70, 147, 90),
                                controlAffinity: ListTileControlAffinity.trailing,
                                value: checkedOptionsatt[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedOptionsatt[index] = value ?? false;
                                    if (value ?? false) {
                                      typeEnt = typeEntOptions[index];
                                    } else {
                                      typeEnt = ''; // Reset if unchecked
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),


                        Divider(height:50, color: Colors.grey),

                        const Text(
                          'طبيعة الفعالية',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'كلاهما';
                                });
                              },
                              text: 'خارجي وداخلي',
                              value: INorOUT == 'كلاهما',
                            ),
                            const SizedBox(width: 10),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'لا';
                                });
                              },
                              text: 'خارجي',
                              value: INorOUT == 'لا',
                            ),
                            const SizedBox(width: 10),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'نعم';
                                });
                              },
                              text: 'داخلي',
                              value: INorOUT == 'نعم',
                            ),
                          ],
                        ),


                        Divider(height:50, color: Colors.grey),

                        const Text(
                          'الحجز',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (hasReservation == false) {
                                    hasReservation = null;
                                  } else {
                                    hasReservation = false;
                                  }
                                });
                              },
                              text: 'يتطلب حجز',
                              value: hasReservation == false,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (hasReservation == true) {
                                    hasReservation = null;
                                  } else {
                                    hasReservation = true;
                                  }
                                });
                              },
                              text: 'لا يتطلب حجز',
                              value: hasReservation == true,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),




                      ],
                    ),
/////////////////////////////////////////////////////////
                  if (type == 2) // Check if the type is for مطاعم
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          ': نوع الطعام',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: cuisineOptions.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    cuisineOptions[index],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Tajawal-m",
                                      color: Color(0xFF6db881),
                                    ),
                                  ),
                                ),
                                activeColor: const Color.fromARGB(
                                    255, 70, 147, 90),
                                controlAffinity: ListTileControlAffinity.trailing,
                                value: checkedOptionsres[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedOptionsres[index] = value ?? false;
                                    if (value ?? false) {
                                      cus = cuisineOptions[index];
                                    } else {
                                      cus = ''; // Reset if unchecked
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),


                        Divider(height:50, color: Colors.grey),

                        const Text(
                          ': نطاق الأسعار',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: WrapAlignment.end,
                          children: priceRange.map((prc) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (price.contains(prc)) {
                                      price.remove(prc);
                                    } else {
                                      price.add(prc);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: price.contains(prc)
                                          ? const Color(0xFF6db881)
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(prc,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      price.contains(prc)
                                          ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Color(0xFF6db881),
                                      )
                                          : const SizedBox(
                                        width: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),
                        Divider(height:50, color: Colors.grey),



                        const Text(
                          ': الوجبات المقدمة ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: WrapAlignment.end,
                          children: servesOptions.map((serve) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (serves.contains(serve)) {
                                      serves.remove(serve);
                                    } else {
                                      serves.add(serve);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: serves.contains(serve)
                                          ? const Color(0xFF6db881)
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(serve,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      serves.contains(serve)
                                          ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Color(0xFF6db881),
                                      )
                                          : const SizedBox(
                                        width: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),



                        Divider(height:50, color: Colors.grey),




                        const Text(
                          ' : الجو العام',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: WrapAlignment.end,
                          children: atmosphereOptions.map((atmosphereOption) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (atmosphere.contains(atmosphereOption)) {
                                      atmosphere.remove(atmosphereOption);
                                    } else {
                                      atmosphere.add(atmosphereOption);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color:
                                      atmosphere.contains(atmosphereOption)
                                          ? const Color(0xFF6db881)
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(atmosphereOption,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      atmosphere.contains(atmosphereOption)
                                          ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Color(0xFF6db881),
                                      )
                                          : const SizedBox(
                                        width: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),

                        Divider(height:50, color: Colors.grey),




                        const Text(
                          'هل يتطلب حجز ؟ ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (hasReservation == false) {
                                    hasReservation = null;
                                  } else {
                                    hasReservation = false;
                                  }
                                });
                              },
                              text: 'يتطلب حجز',
                              value: hasReservation == false,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  // If the current option is selected, undo the selection
                                  if (hasReservation == true) {
                                    hasReservation = null;
                                  } else {
                                    hasReservation = true;
                                  }
                                });
                              },
                              text: 'لا يتطلب حجز',
                              value: hasReservation == true,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),





                      ],
                    ),

                  if (type == 3)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        const SizedBox(height: 10),


                        const Text(
                          'طبيعة المركز',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'كلاهما';
                                });
                              },
                              text: 'خارجي وداخلي',
                              value: INorOUT == 'كلاهما',
                            ),
                            const SizedBox(width: 10),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'لا';
                                });
                              },
                              text: 'خارجي',
                              value: INorOUT == 'لا',
                            ),
                            const SizedBox(width: 10),
                            CustomRadioButton(
                              onTap: () {
                                setState(() {
                                  INorOUT = 'نعم';
                                });
                              },
                              text: 'داخلي',
                              value: INorOUT == 'نعم',
                            ),
                          ],
                        ),

                        Divider(height:50, color: Colors.grey),

                        const Text(
                         'يوجد في مراكز التسوق',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Tajawal-b",
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: isThereInMalls.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    isThereInMalls[index],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Tajawal-m",
                                      color: Color(0xFF6db881),
                                    ),
                                  ),
                                ),
                                activeColor: const Color.fromARGB(
                                    255, 70, 147, 90),
                                controlAffinity: ListTileControlAffinity.trailing,
                                value: checkedOptionsmalls[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedOptionsmalls[index] = value ?? false;
                                    if (value ?? false) {
                                      typeEnt = isThereInMalls[index];
                                    } else {
                                      typeEnt = ''; // Reset if unchecked
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),



                        Divider(height:50, color: Colors.grey),

                        const Text(
                          'أنواع المحلات',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Tajawal-b",
                          ),
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 10,
                          runSpacing: 7,
                          alignment: WrapAlignment.end,
                          children: shopOptions.map((ShopType) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (shopType.contains(ShopType)) {
                                      shopType.remove(ShopType);
                                    } else {
                                      shopType.add(ShopType);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: shopType.contains(ShopType)
                                          ? const Color(0xFF6db881)
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(ShopType,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal-m')),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      shopType.contains(ShopType)
                                          ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Color(0xFF6db881),
                                      )
                                          : const SizedBox(
                                        width: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ));
                          }).toList(),
                        ),
                      ],),




                  const SizedBox(
                    width: 10,
                  ),
                  if ( type == 1 || type == 2 || type == 3)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: (){
                              resetFilterState();

                            },

                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white),
                              elevation: MaterialStateProperty.all(2),
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Color(0xFF6db881)),
                                ),
                              ),
                            ),
                            child: const Text(
                              'مسح الكل',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Tajawal-m",
                                color: Color(0xFF6db881),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {

                              saveFilterState();
                              List<String> typeEntNames = getCheckedOptionNames(typeEntOptions, checkedOptionsatt);
                              List<String> cusNames = getCheckedOptionNames(cuisineOptions, checkedOptionsres);
                              List<String> typeEntInMallsNames = getCheckedOptionNames(isThereInMalls, checkedOptionsmalls);
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context, {
                                  "type": type,
                                  "typeEntNames": type == 1 ? typeEntNames : null,
                                  "INorOUT": type == 1 || type == 3 ? INorOUT : '',
                                  "hasReservation": type == 1 || type == 2 ? hasReservation : null,
                                  "cusNames": type == 2 ? cusNames : null,
                                  "price": type == 2 ? price : null,
                                  "serves": type == 2 ? serves : null,
                                  "atmosphere": type == 2 ? atmosphere : null,
                                  "typeEntInMallsNames": type == 3 ? typeEntInMallsNames : null,
                                  "shopType": type == 3 ? shopType : null,
                                });
                              }
                            },

                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFF6db881)),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const Text(
                              'عرض النتائج',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Tajawal-m",
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),











                ],
              ),

            ),
            ),
          ),
        ),

      ],
    );
  }





  List<String> getCheckedOptionNames(List<String> options, List<bool> checkedOptions) {
    List<String> checkedNames = [];

    for (int index = 0; index < options.length; index++) {
      if (checkedOptions[index]) {
        checkedNames.add(options[index]);
      }
    }

    return checkedNames;
  }

}
