class AlarmEntity {
  AlarmEntity({
    required this.id,
    required this.time,
    required this.status,
    this.isRepeat,
    this.weekdays,
  });
  final int id;
  final DateTime time;
  final String status;
  final bool? isRepeat;
  final List<String>? weekdays;

  String getTimeFormatHHMM() {
    return '${time.hour}:${time.minute}';
  }
}
