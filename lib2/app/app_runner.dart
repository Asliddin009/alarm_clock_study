import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'app.dart';
import 'app_env.dart';
import '../di/app_depends.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppRuner {
  AppRuner(this.appEnv);
  final AppEnv appEnv;
  Future<void> run() async {
    await runZonedGuarded(() async {
      await initApp();
      final appDepends = AppDepends(appEnv);
      await appDepends.init(
        onError: (name, error, stackTrace) {
          throw Exception('$name: $error, $stackTrace');
        },
        onProgress: (name, progresss) {
          log('Init $name progress $progresss%');
        },
      );
      runApp(App(appDepends: appDepends));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.allowFirstFrame();
      });
    }, (error, stack) {
      log(error.toString(), stackTrace: stack, error: error);
      runApp(_AppErrorWidget(message: error.toString()));
    });
  }

  Future<void> initApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Alarm.init();

    WidgetsBinding.instance.deferFirstFrame();
  }
}

class _AppErrorWidget extends StatelessWidget {
  const _AppErrorWidget({required this.message});

  final String message;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}