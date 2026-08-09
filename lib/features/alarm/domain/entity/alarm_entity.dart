import 'dart:convert';

import 'package:equatable/equatable.dart';

class AlarmEntity extends Equatable {
  const AlarmEntity({
    required this.id,
    required this.time,
    required this.isActive,
    this.isRepeat = false,
    this.weekdays = const <Weekday>[],
    this.vibrate = true,
    this.volume = 0.5,
    this.listCategoryIds = const <int>[],
    this.assetAudioPath = defaultAudioAssetPath,
    this.nativeAlarmId,
  });

  static const String defaultAudioAssetPath = 'assets/music/marimba.mp3';

  final int id;
  final DateTime time;
  final bool isActive;
  final bool isRepeat;
  final List<Weekday> weekdays;
  final bool vibrate;
  final double volume;
  final List<int> listCategoryIds;
  final String assetAudioPath;

  /// Identifier the operating system gave this alarm when it was scheduled.
  ///
  /// AlarmKit hands out a UUID that is the only handle for cancelling or
  /// stopping the alarm, so it has to survive an app restart — the alarm may
  /// well outlive the process that created it.
  final String? nativeAlarmId;

  factory AlarmEntity.fromJson(Map<String, dynamic> json) {
    final rawWeekdays = json['weekdays'];
    final parsedWeekdays = rawWeekdays is List
        ? rawWeekdays
              .map((dynamic value) => Weekday.values.byName(value.toString()))
              .toList(growable: false)
        : const <Weekday>[];
    final rawCategoryIds = json['listCategoryIds'] ?? json['listCategoryId'];
    final parsedCategoryIds = rawCategoryIds is List
        ? rawCategoryIds
              .map((dynamic value) => int.parse(value.toString()))
              .toList(growable: false)
        : const <int>[];
    final isRepeat = switch (json['isRepeat']) {
      bool value => value,
      null => parsedWeekdays.isNotEmpty,
      _ => json['isRepeat'].toString().toLowerCase() == 'true',
    };

    return AlarmEntity(
      id: (json['id'] ?? json['alarmId']) as int,
      time: DateTime.parse(json['time'].toString()),
      isActive: json['isActive'] as bool? ?? true,
      isRepeat: isRepeat,
      weekdays: parsedWeekdays,
      vibrate: json['vibrate'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.5,
      listCategoryIds: parsedCategoryIds,
      assetAudioPath: _normalizeAssetAudioPath(
        json['assetAudioPath'] as String?,
      ),
      nativeAlarmId: json['nativeAlarmId'] as String?,
    );
  }

  factory AlarmEntity.fromEncodedJson(String source) {
    return AlarmEntity.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  AlarmEntity copyWith({
    int? id,
    DateTime? time,
    bool? isActive,
    bool? isRepeat,
    List<Weekday>? weekdays,
    bool? vibrate,
    double? volume,
    List<int>? listCategoryIds,
    String? assetAudioPath,
    String? nativeAlarmId,
    bool clearNativeAlarmId = false,
  }) {
    return AlarmEntity(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      isRepeat: isRepeat ?? this.isRepeat,
      weekdays: weekdays ?? this.weekdays,
      vibrate: vibrate ?? this.vibrate,
      volume: volume ?? this.volume,
      listCategoryIds: listCategoryIds ?? this.listCategoryIds,
      assetAudioPath: assetAudioPath ?? this.assetAudioPath,
      nativeAlarmId: clearNativeAlarmId
          ? null
          : nativeAlarmId ?? this.nativeAlarmId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'isRepeat': isRepeat,
      'weekdays': weekdays
          .map((weekday) => weekday.name)
          .toList(growable: false),
      'vibrate': vibrate,
      'volume': volume,
      'assetAudioPath': assetAudioPath,
      'listCategoryIds': listCategoryIds,
      if (nativeAlarmId != null) 'nativeAlarmId': nativeAlarmId,
    };
  }

  String toEncodedJson() => jsonEncode(toJson());

  static String _normalizeAssetAudioPath(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) {
      return defaultAudioAssetPath;
    }
    if (rawPath.startsWith('assets/music/')) {
      return rawPath;
    }
    if (rawPath.startsWith('assets/')) {
      return 'assets/music/${rawPath.split('/').last}';
    }
    return rawPath;
  }

  /// The next moment this alarm should ring, strictly after [moment].
  ///
  /// A one-shot alarm keeps its [time]. A repeating one is projected onto the
  /// next matching day — daily when no [weekdays] are picked, otherwise the
  /// nearest selected weekday within the coming week.
  DateTime nextOccurrenceAfter(DateTime moment) {
    if (!isRepeat && weekdays.isEmpty) {
      return time;
    }

    final selectedWeekdays = weekdays.isEmpty
        ? Weekday.values.toSet()
        : weekdays.toSet();
    final startOfDay = DateTime(moment.year, moment.month, moment.day);

    // Eight days rather than seven: today may already be past the alarm time,
    // in which case a weekly alarm lands on the same weekday next week.
    for (var offset = 0; offset <= 8; offset += 1) {
      final day = startOfDay.add(Duration(days: offset));
      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );
      if (candidate.isAfter(moment) &&
          selectedWeekdays.contains(Weekday.values[candidate.weekday - 1])) {
        return candidate;
      }
    }
    return time;
  }

  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    time,
    isActive,
    isRepeat,
    weekdays,
    vibrate,
    volume,
    listCategoryIds,
    assetAudioPath,
    nativeAlarmId,
  ];
}

enum Weekday {
  monday('Пн'),
  tuesday('Вт'),
  wednesday('Ср'),
  thursday('Чт'),
  friday('Пт'),
  saturday('Сб'),
  sunday('Вс');

  const Weekday(this.shortLabel);

  final String shortLabel;
}
