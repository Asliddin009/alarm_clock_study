import 'package:alarm/alarm.dart';
import 'features/alarm/ui/alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// void main() async {
//   await AppRuner(AppEnv.test).run();
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init();

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: const ExampleAlarmHomeScreen(),
    ),
  );
}
