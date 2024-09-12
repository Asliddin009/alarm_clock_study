import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter/material.dart';

class AlarmEditWidget extends StatefulWidget {
  const AlarmEditWidget({super.key, this.alarm});
  final AlarmEntity? alarm;

  @override
  State<AlarmEditWidget> createState() => _AlarmEditWidgetState();
}

class _AlarmEditWidgetState extends State<AlarmEditWidget> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;

  @override
  void initState() {
    super.initState();
    creating = widget.alarm == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
    } else {
      selectedDateTime = widget.alarm!.time;
      loopAudio = widget.alarm!.isRepeat ?? false;
      vibrate = widget.alarm!.vibrate;
      volume = widget.alarm!.volume;
      assetAudio = widget.alarm!.assetAudioPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
