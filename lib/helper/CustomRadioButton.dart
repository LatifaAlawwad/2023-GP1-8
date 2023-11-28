import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final bool value;

  CustomRadioButton(
      {required this.onTap, required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 7,bottom: 7, right: 12,left: 14),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: value ? Color(0xFF6db881) : Colors.white,
          border: Border.all(
            color: value ? Color(0xff62a774) : Colors.black54,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: value ? Colors.white : Colors.black,
              fontFamily: 'Tajawal-m',
            ),
          ),
        ),
      ),
    );
  }
}
