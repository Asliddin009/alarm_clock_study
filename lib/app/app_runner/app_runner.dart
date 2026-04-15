import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alearn/app/app_runner/app.dart';
import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppRunner {
  AppRunner(this.appEnv);

  final AppEnv appEnv;

  Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.deferFirstFrame();
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await Alarm.init();
    await Alarm.setNotificationOnAppKillContent(
      'Будильник может не сработать',
      'Если полностью закрыть приложение, будильник может не сработать.',
    );

    runApp(_BootstrapApp(appEnv: appEnv));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.allowFirstFrame();
    });
  }
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp({required this.appEnv});

  final AppEnv appEnv;

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<AppDependencies> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = AppDependencies.create(widget.appEnv);
  }

  void _retryBootstrap() {
    setState(() {
      _bootstrapFuture = AppDependencies.create(widget.appEnv);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return _BootstrapErrorApp(
            error: snapshot.error!,
            onRetry: _retryBootstrap,
          );
        }

        final appDependencies = snapshot.requireData;
        return App(appDependencies: appDependencies);
      },
    );
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Ошибка запуска')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
