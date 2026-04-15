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
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppDependencies {
  const AppDependencies._({
    required this.authRepo,
    required this.alarmRepo,
    required this.alarmCacheRepo,
    required this.alarmService,
    required this.categoryRepo,
    required this.ringQuestionService,
  });

  final IAuthRepo authRepo;
  final IAlarmRepo alarmRepo;
  final IAlarmCacheRepo alarmCacheRepo;
  final AlarmService alarmService;
  final ICategoryRepo categoryRepo;
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
    final categoryRepo = const AssetCategoryRepo();
    final alarmService = AlarmService(
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCacheRepo,
    );

    return AppDependencies._(
      authRepo: MockAuthRepo(),
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCacheRepo,
      alarmService: alarmService,
      categoryRepo: categoryRepo,
      ringQuestionService: RingQuestionService(categoryRepo: categoryRepo),
    );
  }
}
