import '../../../app/ui_kit/components/app_text_button.dart';
import '../../alarm/ui/alarm_screen.dart';
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
          children: [
            const SizedBox(height: 10),
            AppTextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  // ignore: inference_failure_on_instance_creation
                  MaterialPageRoute(
                    builder: (context) => const ExampleAlarmHomeScreen(),
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
