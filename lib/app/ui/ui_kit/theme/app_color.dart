import 'package:flutter/material.dart';

class AppColors {
  // Цвета Const
  static const Color white = Color(0xffFFFFFF);
  static const Color black = Color(0xff141414);

  static Color accent000 = const Color(0xff0469E3).withOpacity(0.16);
  static const Color accent100 = Color(0xff0469E3);
  static const Color accent200 = Color(0xff0B61CA);

  static Color error000 = const Color(0xffD52B1E).withOpacity(0.16);
  static const Color error100 = Color(0xffD52B1E);
  static const Color error200 = Color(0xffB51B1B);

  static Color orange000 = const Color(0xffD3733D).withOpacity(0.16);
  static const Color orange100 = Color(0xffEBAE12);
  static const Color orange200 = Color(0xffD3733D);

  static Color green000 = const Color(0xff43BC45).withOpacity(0.16);
  static const Color green100 = Color(0xff43BC45);
  static const Color green200 = Color(0xff1DA61F);
}

/// Цвета Dark
class DarkColors extends AppColors {
  static const Color primary000 = Color(0xff141414);
  static const Color primary100 = Color(0xffFFFFFF);
  static Color primary200 = const Color(0xffFFFFFF).withOpacity(0.94);
  static Color primary300 = const Color(0xffFFFFFF).withOpacity(0.56);
  static Color primary400 = const Color(0xffFFFFFF).withOpacity(0.1);
  static Color primary500 = const Color(0xffFFFFFF).withOpacity(0.08);
}

/// Цвета Light
class LightColors extends AppColors {
  static const Color primary000 = Color(0xffFFFFFF);
  static const Color primary100 = Color(0xff141414);
  static Color primary200 = const Color(0xff141414).withOpacity(0.94);
  static Color primary300 = const Color(0xff141414).withOpacity(0.56);
  static Color primary400 = const Color(0xff141414).withOpacity(0.1);
  static Color primary500 = const Color(0xff141414).withOpacity(0.04);
}
