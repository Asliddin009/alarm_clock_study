import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_splash_screen.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    return AppSplashScreen(
      title: localizations.splash_title,
      subtitle: localizations.splash_subtitle,
      showLoader: true,
    );
  }
}
