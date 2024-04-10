import 'package:flutter/material.dart';

Widget buildBackground(BuildContext context) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("images.jpg"),
        fit: BoxFit.cover,
      ),
    ),
  );
}