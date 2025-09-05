import 'package:alearn/app/ui/theme/eleveted_button_style.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  hintColor: Colors.grey.withValues(alpha: 0.5),
  elevatedButtonTheme: lightElevatedButtonThemeData,
  scaffoldBackgroundColor: Colors.grey.shade300,
  textTheme: const TextTheme(),
);
