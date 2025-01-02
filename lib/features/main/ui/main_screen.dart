import 'package:alearn/app/ui/ui_kit/app_text_button.dart';
import 'package:alearn/features/alarm/ui/alarm_screen_new.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            AppTextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlarmScreenNew(),
                    // builder: (context) => const ExampleAlarmHomeScreen(),
                  ),
                );
              },
              text: 'Будильник',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
