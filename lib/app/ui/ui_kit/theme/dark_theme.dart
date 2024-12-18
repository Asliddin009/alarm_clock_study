import 'package:alearn/app/ui/ui_kit/theme/eleveted_button_style.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
  hintColor: Colors.grey.withOpacity(0.5),
  elevatedButtonTheme: darkElevatedButtonThemeData,
);
