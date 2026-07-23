import 'package:flutter/material.dart';

class ColorResource {
  ColorResource._();

  static const Color black = Color(0xFF060A0F);
  static const Color white = Color(0xFFF7FAFD);
  static const Color forest = Color(0xFF163B59);
  static const Color forestAccent = Color(0xFF1F6FA8);
  static const Color mint = Color(0xFF8FD3F0);
  static const Color border = Color(0xFFD8E4EE);
  static const Color muted = Color(0xFF63707C);
  static const Color danger = Color(0xFF7A2323);

  static const Color darkScaffold = Color(0xFF050B12);
  static const Color darkSurface = Color(0xFF0D1A24);
  static const Color darkSurfaceSecondary = Color(0xFF13232F);
  static const Color lightScaffold = Color(0xFFF3F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFE8F1F8);
  static const Color overlay = Color(0x22163B59);

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
