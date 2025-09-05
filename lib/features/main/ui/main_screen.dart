import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_text_button.dart';
import 'package:alearn/features/alarm/ui/alarm_screen/alarm_screen_new.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToAlarmScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlarmScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppTextButton(
              onPressed: () => _navigateToAlarmScreen(context),
              text: localizations.alarm,
            ),
          ],
        ),
      ),
    );
  }
}
