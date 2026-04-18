import 'package:flutter/material.dart';

class ColorResource {
  ColorResource._();

  static const Color black = Color(0xFF040706);
  static const Color white = Color(0xFFF7F8F6);
  static const Color forest = Color(0xFF163328);
  static const Color forestAccent = Color(0xFF285441);
  static const Color mint = Color(0xFF9CC6B0);
  static const Color border = Color(0xFFDAE0DB);
  static const Color muted = Color(0xFF64706A);
  static const Color danger = Color(0xFF7A2323);

  static const Color darkScaffold = Color(0xFF050807);
  static const Color darkSurface = Color(0xFF0D1512);
  static const Color darkSurfaceSecondary = Color(0xFF13201B);
  static const Color lightScaffold = Color(0xFFF4F6F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFEAEFEA);
  static const Color overlay = Color(0x22163328);

  static Color black80 = black.withValues(alpha: 0.8);
  static Color registerIcon = muted.withValues(alpha: 0.5);

  static const Color authBgColor = lightScaffold;
  static const Color authBgDarkColor = darkScaffold;
  static const Color primaryButtonColor = forest;
  static const Color textFieldDarkThemeBg = darkSurfaceSecondary;
  static const Color hintColorDarkMode = Color(0xB3F7F8F6);
  static const Color hintColorLightMode = Color(0xA3040706);
  static const Color red = danger;
  static const Color green = mint;
}
