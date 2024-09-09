import 'dart:io';

import '../app/app_env.dart';
import '../features/alarm/data/android_alarm_repo.dart';
import '../features/alarm/data/ios_alarm_repo.dart';
import '../features/alarm/domain/i_alarm_repo.dart';
import '../features/auth/data/mock_app_repo.dart';
import '../features/auth/data/prod_app_repo.dart';
import '../features/auth/domain/i_auth_repo.dart';
import 'package:flutter/foundation.dart';

typedef OnError = void Function(
  String name,
  Object error,
  StackTrace stackTrace,
);
typedef OnProgress = void Function(String name, String progresss);

enum _AppDeps { authRepo, alarmRepo }

final class AppDepends {
  AppDepends(
    this.appEnv,
  );
  late final IAuthRepo authRepo;
  late final IAlarmRepo alarmRepo;
  final AppEnv appEnv;
  Future<void> init({
    required OnError onError,
    required OnProgress onProgress,
  }) async {
    ///AuthRepo
    try {
      authRepo = switch (appEnv) {
        AppEnv.test => MockAuthRepo(),
        AppEnv.prod => ProdAuthRepo()
      };
      onProgress(
        'authRepo',
        _calc(_AppDeps.authRepo.index, _AppDeps.values.length),
      );
    } on Exception catch (error, stackTrace) {
      onError('authRepo', error, stackTrace);
    }

    ///AlarmRepo
    try {
      if (kIsWeb) {
        onProgress(
          'alarmRepo',
          _calc(_AppDeps.alarmRepo.index, _AppDeps.values.length),
        );
        return;
      }
      final isAndroid = Platform.isAndroid;
      alarmRepo = switch (isAndroid) {
        true => AndroidAlarmRepo(),
        false => IosAlarmRepo()
      };
      onProgress(
        'alarmRepo',
        _calc(_AppDeps.alarmRepo.index, _AppDeps.values.length),
      );
    } on Exception catch (error, stackTrace) {
      onError('alarmRepo', error, stackTrace);
    }
  }

  String _calc(int current, int total) {
    return ((current + 1) / total * 100).toStringAsFixed(0);
  }
}
