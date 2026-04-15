import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExampleAlarmHomeShortcutButton extends StatefulWidget {
  const ExampleAlarmHomeShortcutButton({super.key});

  @override
  State<ExampleAlarmHomeShortcutButton> createState() =>
      _ExampleAlarmHomeShortcutButtonState();
}

class _ExampleAlarmHomeShortcutButtonState
    extends State<ExampleAlarmHomeShortcutButton> {
  bool showMenu = false;

  void _scheduleQuickAlarm(int delayInHours) {
    var dateTime = DateTime.now().add(Duration(hours: delayInHours));
    if (delayInHours != 0) {
      dateTime = dateTime.copyWith(second: 0, millisecond: 0, microsecond: 0);
    }

    context.read<AlarmBloc>().add(
          AlarmCreateRequested(
            dateTime: dateTime,
            isRepeat: false,
            weekdays: const [],
            categoryIds: const [],
          ),
        );

    setState(() => showMenu = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onLongPress: () => setState(() => showMenu = true),
          child: FloatingActionButton(
            onPressed: () => _scheduleQuickAlarm(0),
            backgroundColor: Colors.redAccent,
            heroTag: 'quick-alarm',
            child: const Text('RING\nNOW', textAlign: TextAlign.center),
          ),
        ),
        if (showMenu)
          Row(
            children: [
              TextButton(
                onPressed: () => _scheduleQuickAlarm(24),
                child: const Text('+24h'),
              ),
              TextButton(
                onPressed: () => _scheduleQuickAlarm(36),
                child: const Text('+36h'),
              ),
              TextButton(
                onPressed: () => _scheduleQuickAlarm(48),
                child: const Text('+48h'),
              ),
            ],
          ),
      ],
    );
  }
}
