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
  });

  static const String defaultAudioAssetPath = 'assets/marimba.mp3';

  final int id;
  final DateTime time;
  final bool isActive;
  final bool isRepeat;
  final List<Weekday> weekdays;
  final bool vibrate;
  final double volume;
  final List<int> listCategoryIds;
  final String assetAudioPath;

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
      assetAudioPath:
          json['assetAudioPath'] as String? ?? AlarmEntity.defaultAudioAssetPath,
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
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'isRepeat': isRepeat,
      'weekdays': weekdays.map((weekday) => weekday.name).toList(growable: false),
      'vibrate': vibrate,
      'volume': volume,
      'assetAudioPath': assetAudioPath,
      'listCategoryIds': listCategoryIds,
    };
  }

  String toEncodedJson() => jsonEncode(toJson());

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
