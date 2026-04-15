import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';

class RecordingAlarmRepo implements IAlarmRepo {
  final List<AlarmEntity> scheduled = <AlarmEntity>[];
  final List<AlarmEntity> updated = <AlarmEntity>[];
  final List<int> deletedIds = <int>[];
  final StreamController<AlarmSettings> ringController =
      StreamController<AlarmSettings>.broadcast();

  bool failOnSchedule = false;
  bool failOnUpdate = false;
  bool failOnDelete = false;
  bool permissionsRequested = false;

  @override
  Stream<AlarmSettings> get ringStream => ringController.stream;

  @override
  Future<void> requestPermissions() async {
    permissionsRequested = true;
  }

  @override
  Future<void> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    if (failOnSchedule) {
      throw const AlarmRepositoryException('schedule failed');
    }
    scheduled.add(alarm);
  }

  @override
  Future<void> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    if (failOnUpdate) {
      throw const AlarmRepositoryException('update failed');
    }
    updated.add(alarm);
  }

  @override
  Future<void> deleteAlarm(int id) async {
    if (failOnDelete) {
      throw const AlarmRepositoryException('delete failed');
    }
    deletedIds.add(id);
  }

  Future<void> dispose() => ringController.close();
}

class InMemoryAlarmCacheRepo implements IAlarmCacheRepo {
  InMemoryAlarmCacheRepo([List<AlarmEntity>? initialAlarms])
      : _alarms = <AlarmEntity>[...initialAlarms ?? const <AlarmEntity>[]];

  final List<AlarmEntity> _alarms;
  bool failOnSave = false;
  bool failOnUpdate = false;
  bool failOnDelete = false;
  bool failOnGetAll = false;

  List<AlarmEntity> get alarms => List<AlarmEntity>.unmodifiable(_alarms);

  @override
  Future<List<AlarmEntity>> getAll() async {
    if (failOnGetAll) {
      throw const AlarmCacheException('getAll failed');
    }
    return <AlarmEntity>[..._alarms];
  }

  @override
  Future<void> save(AlarmEntity alarm) async {
    if (failOnSave) {
      throw const AlarmCacheException('save failed');
    }
    _alarms.add(alarm);
  }

  @override
  Future<void> update(AlarmEntity alarm) async {
    if (failOnUpdate) {
      throw const AlarmCacheException('update failed');
    }
    final index = _alarms.indexWhere((currentAlarm) => currentAlarm.id == alarm.id);
    if (index >= 0) {
      _alarms[index] = alarm;
    }
  }

  @override
  Future<void> delete(int id) async {
    if (failOnDelete) {
      throw const AlarmCacheException('delete failed');
    }
    _alarms.removeWhere((alarm) => alarm.id == id);
  }
}

class FakeCategoryRepo implements ICategoryRepo {
  FakeCategoryRepo({
    this.baseCategories = const <CategoryEntity>[],
    this.categories = const <CategoryEntity>[],
    this.throwOnGet = false,
  });

  final List<CategoryEntity> baseCategories;
  final List<CategoryEntity> categories;
  final bool throwOnGet;

  @override
  Future<List<CategoryEntity>> getBaseCategories() async {
    if (throwOnGet) {
      throw Exception('failed to load categories');
    }
    return baseCategories;
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    if (throwOnGet) {
      throw Exception('failed to load categories');
    }
    return categories;
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    final allCategories = <CategoryEntity>[...baseCategories, ...categories];
    for (final category in allCategories) {
      if (category.name == name) {
        return category;
      }
    }
    return null;
  }
}
