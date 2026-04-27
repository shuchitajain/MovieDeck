import 'package:flutter/material.dart';

Widget backButton(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
        child: Icon(
          Icons.keyboard_arrow_left,
          color: Theme.of(context).colorScheme.onSurface,
          size: 35,
        ),
      ),
    ),
  );
}
