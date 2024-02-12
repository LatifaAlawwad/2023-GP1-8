import 'package:flutter/material.dart';

class ShowINorOUtAttributesWidget extends StatelessWidget {
  final String text;

  const ShowINorOUtAttributesWidget({
    Key? key,

    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF6db881) ,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 25,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 16.0, fontFamily: 'Tajawal-m'),
          ),
          const SizedBox(
            width: 5,
          ),
          const Icon(
            Icons.check_rounded,
            size: 16,
            color: Color(0xFF6db881),
          ),

          const SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }
}
