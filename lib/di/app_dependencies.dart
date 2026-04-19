import 'package:alearn/app/data/shared_pref_app_preferences_repo.dart';
import 'package:alearn/app/domain/i_app_preferences_repo.dart';
import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/features/alarm/data/alarm_plus_repo.dart';
import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/data/shared_pref_alarm_cache.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:alearn/features/auth/domain/i_auth_repo.dart';
import 'package:alearn/features/category/data/asset_category_repo.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:alearn/features/points/data/shared_pref_points_repo.dart';
import 'package:alearn/features/points/domain/i_points_repo.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppDependencies {
  const AppDependencies._({
    required this.authRepo,
    required this.appPreferencesRepo,
    required this.alarmRepo,
    required this.alarmCacheRepo,
    required this.alarmService,
    required this.categoryRepo,
    required this.pointsRepo,
    required this.ringQuestionService,
  });

  factory AppDependencies.testing({
    required IAuthRepo authRepo,
    required IAppPreferencesRepo appPreferencesRepo,
    required IAlarmRepo alarmRepo,
    required IAlarmCacheRepo alarmCacheRepo,
    required AlarmService alarmService,
    required ICategoryRepo categoryRepo,
    required IPointsRepo pointsRepo,
    required RingQuestionService ringQuestionService,
  }) {
    return AppDependencies._(
      authRepo: authRepo,
      appPreferencesRepo: appPreferencesRepo,
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCacheRepo,
      alarmService: alarmService,
      categoryRepo: categoryRepo,
      pointsRepo: pointsRepo,
      ringQuestionService: ringQuestionService,
    );
  }

  final IAuthRepo authRepo;
  final IAppPreferencesRepo appPreferencesRepo;
  final IAlarmRepo alarmRepo;
  final IAlarmCacheRepo alarmCacheRepo;
  final AlarmService alarmService;
  final ICategoryRepo categoryRepo;
  final IPointsRepo pointsRepo;
  final RingQuestionService ringQuestionService;

  static Future<AppDependencies> create(AppEnv env) async {
    if (env == AppEnv.prod) {
      throw UnsupportedError(
        'AppEnv.prod is not implemented yet. Use the default entrypoint for the mock environment.',
      );
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    final alarmRepo = kIsWeb
        ? const UnsupportedAlarmRepo(platformName: 'web')
        : AlarmPlusRepo(permissionService: const AlarmPermissionService());
    final alarmCacheRepo = SharedPrefAlarmCache(sharedPreferences);
    final appPreferencesRepo = SharedPrefAppPreferencesRepo(sharedPreferences);
    final categoryRepo = const AssetCategoryRepo();
    final pointsRepo = SharedPrefPointsRepo(sharedPreferences);
    final alarmService = AlarmService(
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCacheRepo,
    );

    return AppDependencies._(
      authRepo: MockAuthRepo(sharedPreferences),
      appPreferencesRepo: appPreferencesRepo,
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCacheRepo,
      alarmService: alarmService,
      categoryRepo: categoryRepo,
      pointsRepo: pointsRepo,
      ringQuestionService: RingQuestionService(categoryRepo: categoryRepo),
    );
  }
}
