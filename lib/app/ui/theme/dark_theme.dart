import 'package:alearn/app/ui/theme/eleveted_button_style.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
  hintColor: Colors.grey.withValues(alpha: 0.5),
  elevatedButtonTheme: darkElevatedButtonThemeData,
);
