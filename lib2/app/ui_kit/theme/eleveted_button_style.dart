import 'package:flutter/material.dart';

final lightElevatedButtonThemeData = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.blueAccent),
    fixedSize: WidgetStateProperty.all<Size>(const Size(double.maxFinite, 40)),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  ),
);

final darkElevatedButtonThemeData = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.blueAccent),
    fixedSize: WidgetStateProperty.all<Size>(const Size(double.maxFinite, 40)),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  ),
);
