import 'package:flutter/material.dart';

class ShowBoolAttributesWidget extends StatelessWidget {
  final bool check;
  final String text;

  const ShowBoolAttributesWidget({
    Key? key,
    required this.check,
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
          color: check ? const Color(0xFF6db881) : Colors.black,
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
          check
              ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF6db881),
                )
              : const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red,
                ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }
}
