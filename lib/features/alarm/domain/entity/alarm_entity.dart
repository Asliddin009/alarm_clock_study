class AlarmEntity {
  AlarmEntity({
    required this.id,
    required this.time,
    required this.isActive,
    this.isRepeat,
    this.weekdays,
    this.vibrate = true,
    this.volume = 0.5,
    this.listCategoryId = const [],
    this.assetAudioPath = 'assets/marimba.mp3',
  });

  factory AlarmEntity.fromString(String str) {
    final list = str.split(';');
    final id = int.parse(list[0]);
    final time = DateTime.parse(list[1]);
    final isActive = list[2];
    final isRepeat = list[3] == 'true';
    final weekdays = list[4] == 'null' ? null : list[4].split('|').map((e) => Weekday.values.byName(e)).toList();
    final listCategoryId = list[5] == 'null' ? null : list[5].split('|').map((e) => int.parse(e)).toList();
    return AlarmEntity(
      id: id,
      time: time,
      isActive: bool.parse(isActive),
      isRepeat: isRepeat,
      weekdays: weekdays,
      listCategoryId: listCategoryId ?? [],
    );
  }

  final int id;
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

  @override
  String toString() {
    return '$id;$time;$isActive;$isRepeat;$weekdays;${listCategoryId.join('|')}';
  }
}

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
