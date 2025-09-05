import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExampleAlarmHomeShortcutButton extends StatefulWidget {
  const ExampleAlarmHomeShortcutButton({
    required this.refreshAlarms,
    super.key,
  });
  final void Function() refreshAlarms;

  @override
  State<ExampleAlarmHomeShortcutButton> createState() => _ExampleAlarmHomeShortcutButtonState();
}

class _ExampleAlarmHomeShortcutButtonState extends State<ExampleAlarmHomeShortcutButton> {
  bool showMenu = false;

  Future<void> onPressButton(int delayInHours) async {
    var dateTime = DateTime.now().add(Duration(hours: delayInHours));

    if (delayInHours != 0) {
      dateTime = dateTime.copyWith(second: 0, millisecond: 0);
    }
    context.read<AlarmBloc>().add(
          AlarmCreateEvent(
            dateTime: dateTime,
            isRepeat: true,
            weekdays: [],
            listCategoryId: [],
          ),
        );

    setState(() => showMenu = false);

    // final alarmSettings = AlarmSettings(
    //   id: DateTime.now().millisecondsSinceEpoch % 10000,
    //   dateTime: dateTime,
    //   assetAudioPath: 'assets/star_wars.mp3',
    //   volume: 0,
    //   loopAudio: false,
    //   notificationTitle: 'Alarm example',
    //   notificationBody: '',
    //   enableNotificationOnKill: Platform.isIOS,
    // );

    // await Alarm.set(alarmSettings: alarmSettings);

    // widget.refreshAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onLongPress: () {
            setState(() => showMenu = true);
          },
          child: FloatingActionButton(
            onPressed: () => onPressButton(0),
            backgroundColor: Colors.red,
            heroTag: null,
            child: const Text('RING NOW', textAlign: TextAlign.center),
          ),
        ),
        if (showMenu)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => onPressButton(24),
                child: const Text('+24h'),
              ),
              TextButton(
                onPressed: () => onPressButton(36),
                child: const Text('+36h'),
              ),
              TextButton(
                onPressed: () => onPressButton(48),
                child: const Text('+48h'),
              ),
            ],
          ),
      ],
    );
  }
}
