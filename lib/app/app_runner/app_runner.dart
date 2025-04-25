import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:alearn/app/app_runner/app.dart';
import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/di/app_depends.dart';
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
    await Alarm.setNotificationOnAppKillContent(
      'Будильник может не сработать',
      'Вы закрыли приложение из-за чего может не сработать будильник',
    );
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
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              const Icon(
                Icons.error,
                size: 45,
                color: Colors.red,
              ),
              Text(message),
              ElevatedButton(
                onPressed: () {
                  _restartApp();
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartApp() {
    WidgetsBinding.instance.reassembleApplication();
  }
}
