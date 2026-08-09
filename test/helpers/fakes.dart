import 'dart:async';

import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_progress_repo.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:alearn/features/points/domain/i_points_repo.dart';

class RecordingAlarmRepo implements IAlarmRepo {
  RecordingAlarmRepo({
    this.supportsNativeRecurrence = true,
    this.nativeAlarmIdPrefix = 'native-',
  });

  final List<AlarmEntity> scheduled = <AlarmEntity>[];
  final List<AlarmEntity> updated = <AlarmEntity>[];
  final List<int> deletedIds = <int>[];
  final List<int> stoppedIds = <int>[];
  final StreamController<int> ringController =
      StreamController<int>.broadcast();

  /// Ids the fake system reports as still scheduled; null means "all of them".
  Set<int>? systemScheduledIds;
  Set<int> systemRingingIds = <int>{};

  bool failOnSchedule = false;
  bool failOnUpdate = false;
  bool failOnDelete = false;
  bool permissionsRequested = false;

  @override
  final bool supportsNativeRecurrence;

  final String nativeAlarmIdPrefix;

  @override
  bool get ringsWhenAppIsTerminated => true;

  @override
  Stream<int> get ringStream => ringController.stream;

  @override
  Future<void> requestPermissions() async {
    permissionsRequested = true;
  }

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    if (failOnSchedule) {
      throw const AlarmRepositoryException('schedule failed');
    }
    scheduled.add(alarm);
    return alarm.copyWith(nativeAlarmId: '$nativeAlarmIdPrefix${alarm.id}');
  }

  @override
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    if (failOnUpdate) {
      throw const AlarmRepositoryException('update failed');
    }
    updated.add(alarm);
    return alarm.copyWith(nativeAlarmId: '$nativeAlarmIdPrefix${alarm.id}');
  }

  @override
  Future<void> deleteAlarm({required int id, String? nativeAlarmId}) async {
    if (failOnDelete) {
      throw const AlarmRepositoryException('delete failed');
    }
    deletedIds.add(id);
  }

  @override
  Future<void> stopAlarm({required int id, String? nativeAlarmId}) async {
    stoppedIds.add(id);
  }

  @override
  Future<Set<int>> getScheduledAlarmIds(List<AlarmEntity> alarms) async {
    final knownIds = alarms.map((alarm) => alarm.id).toSet();
    return systemScheduledIds?.intersection(knownIds) ?? knownIds;
  }

  @override
  Future<Set<int>> getRingingAlarmIds(List<AlarmEntity> alarms) async {
    return systemRingingIds.intersection(
      alarms.map((alarm) => alarm.id).toSet(),
    );
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
    final index = _alarms.indexWhere(
      (currentAlarm) => currentAlarm.id == alarm.id,
    );
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

class InMemoryCategoryProgressRepo implements ICategoryProgressRepo {
  final Set<int> _favoriteIds = <int>{};
  final Map<int, Set<int>> _studiedByCategory = <int, Set<int>>{};

  @override
  Future<Set<int>> getFavoriteIds() async => <int>{..._favoriteIds};

  @override
  Future<Set<int>> toggleFavorite(int categoryId) async {
    if (!_favoriteIds.remove(categoryId)) {
      _favoriteIds.add(categoryId);
    }
    return <int>{..._favoriteIds};
  }

  @override
  Future<Set<int>> getStudiedWordIndexes(int categoryId) async => <int>{
    ...?_studiedByCategory[categoryId],
  };

  @override
  Future<Set<int>> markWordStudied(int categoryId, int wordIndex) async {
    final studied = _studiedByCategory.putIfAbsent(categoryId, () => <int>{});
    studied.add(wordIndex);
    return <int>{...studied};
  }
}

class InMemoryPointsRepo implements IPointsRepo {
  InMemoryPointsRepo([this._balance = 12]);

  int _balance;

  @override
  Future<int> addPoints(int amount) async {
    _balance += amount;
    return _balance;
  }

  @override
  Future<int> getBalance() async => _balance;

  @override
  Future<int> spendPoints(int amount) async {
    if (_balance < amount) {
      throw StateError('Not enough points.');
    }
    _balance -= amount;
    return _balance;
  }
}
