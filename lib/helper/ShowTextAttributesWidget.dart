import 'package:flutter/material.dart';
import 'package:gp/language_constants.dart';
class ShowTextAttributesWidget extends StatelessWidget {
  final String text;

  ShowTextAttributesWidget({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(
          height: 5,
        ),
      Text(
          translation(context).resDetails,
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
          text,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
