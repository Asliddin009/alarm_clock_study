import 'dart:io';

import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/features/alarm/data/alarm_plus_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:alearn/features/auth/data/prod_app_repo.dart';
import 'package:alearn/features/auth/domain/i_auth_repo.dart';
import 'package:alearn/features/category/data/mock_category_repo.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:flutter/foundation.dart';

typedef OnError = void Function(
  String name,
  Object error,
  StackTrace stackTrace,
);
typedef OnProgress = void Function(String name, String progresss);

enum _AppDeps { authRepo, alarmRepo, categoryRepo }

final class AppDepends {
  AppDepends(
    this.appEnv,
  );
  late final IAuthRepo authRepo;
  late final IAlarmRepo alarmRepo;
  late final ICategoryRepo categoryRepo;
  final AppEnv appEnv;
  Future<void> init({
    required OnError onError,
    required OnProgress onProgress,
  }) async {
    ///AuthRepo
    try {
      authRepo = switch (appEnv) { AppEnv.test => MockAuthRepo(), AppEnv.prod => ProdAuthRepo() };
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
        true => AlarmPlusRepo(),
        false => AlarmPlusRepo()
        // false => IosAlarmRepo()
      };
      onProgress(
        'alarmRepo',
        _calc(_AppDeps.alarmRepo.index, _AppDeps.values.length),
      );
    } on Exception catch (error, stackTrace) {
      onError('alarmRepo', error, stackTrace);
    }

    //CategoryRepo
    try {
      if (kIsWeb) {
        onProgress(
          'categoryRepo',
          _calc(_AppDeps.categoryRepo.index, _AppDeps.values.length),
        );
        return;
      }
      categoryRepo = switch (appEnv) { AppEnv.test => MockCategoryRepo(), AppEnv.prod => MockCategoryRepo() };
      onProgress(
        'categoryRepo',
        _calc(_AppDeps.categoryRepo.index, _AppDeps.values.length),
      );
    } on Exception catch (error, stackTrace) {
      onError('categoryRepo', error, stackTrace);
    }
  }

  String _calc(int current, int total) {
    return ((current + 1) / total * 100).toStringAsFixed(0);
  }
}
