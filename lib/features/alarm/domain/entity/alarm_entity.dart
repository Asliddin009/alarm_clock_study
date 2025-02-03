import 'dart:convert';

class AlarmEntity {
  AlarmEntity({
    required this.id,
    required this.alarmId,
    required this.time,
    required this.isActive,
    this.isRepeat,
    this.weekdays,
    this.vibrate = true,
    this.volume = 0.5,
    this.listCategoryId = const [],
    this.assetAudioPath = 'assets/marimba.mp3',
  });

  final int id;
  final int alarmId;
  final DateTime time;
  final bool isActive;
  final bool? isRepeat;
  final List<Weekday>? weekdays;
  final bool vibrate;
  final double volume;
  final String assetAudioPath;
  final List<int> listCategoryId;

  String getTimeFormatHHMM() {
    return '${time.hour}:${time.minute}';
  }

  factory AlarmEntity.fromString(String str) {
    // Декодируем JSON-строку в Map
    final Map<String, dynamic> json = jsonDecode(str);

    return AlarmEntity(
      id: json['id'],
      alarmId: json['alarmId'],
      time: DateTime.parse(json['time']),
      isActive: json['isActive'],
      isRepeat: json['isRepeat'],
      weekdays:
          json['weekdays'] != null ? (json['weekdays'] as List).map((e) => Weekday.values.byName(e)).toList() : null,
      vibrate: json['vibrate'] ?? true,
      volume: (json['volume'] as num).toDouble(), // Для обработки double
      assetAudioPath: json['assetAudioPath'] ?? 'assets/marimba.mp3',
      listCategoryId:
          json['listCategoryId'] != null ? (json['listCategoryId'] as List).map((e) => e as int).toList() : [],
    );
  }

  @override
  String toString() {
    // Преобразуем объект в Map и затем сериализуем в JSON
    final Map<String, dynamic> json = {
      'id': id,
      'alarmId': alarmId,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'isRepeat': isRepeat,
      'weekdays': weekdays?.map((e) => e.name).toList(),
      'vibrate': vibrate,
      'volume': volume,
      'assetAudioPath': assetAudioPath,
      'listCategoryId': listCategoryId,
    };

    return jsonEncode(json);
  }
}

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
