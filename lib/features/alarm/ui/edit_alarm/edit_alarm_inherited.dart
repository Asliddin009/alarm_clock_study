import 'dart:developer';

import 'package:alearn/features/alarm/ui/edit_alarm/components/weekday_picker/weekday_type.dart';
import 'package:flutter/material.dart';

class EditAlarmInherited extends StatefulWidget {
  const EditAlarmInherited({required this.child, super.key});
  final Widget child;

  @override
  State<EditAlarmInherited> createState() => _EditAlarmInheritedState();
}

class _EditAlarmInheritedState extends State<EditAlarmInherited> {
  DateTime? selectedDate; // Выбранная дата
  List<WeekdayType> selectedDays = []; // Выбранные дни недели
  bool isRepeat = false;

  void _onSelectDate(DateTime date) {
    selectedDate = date;
  }

  void _onSelectWeekday(WeekdayType weekday) {
    if (selectedDays.contains(weekday)) {
      selectedDays.remove(weekday);
    } else {
      selectedDays.add(weekday);
    }
  }

  void _onSelectRepeat(bool isRepeat) {
    setState(() {
      this.isRepeat = isRepeat;
    });
  }

  @override
  Widget build(BuildContext context) {
    log('build EditAlarmInherited');
    return EditAlarmProvider(
      selectedDays: selectedDays,
      onSelecteWeekday: _onSelectWeekday,
      onSelectDate: _onSelectDate,
      onSelectRepeat: _onSelectRepeat,
      isRepeat: isRepeat,
      date: selectedDate,
      child: widget.child,
    );
  }
}

class EditAlarmProvider extends InheritedWidget {
  //дни недели
  final List<WeekdayType> selectedDays;
  final void Function(WeekdayType weekday) onSelecteWeekday;
  //дата
  final DateTime? date;
  final void Function(DateTime date) onSelectDate;
  //будет ли повторяться
  final bool isRepeat;
  final void Function(bool isRepeat) onSelectRepeat;

  const EditAlarmProvider({
    required this.selectedDays,
    required this.onSelecteWeekday,
    required super.child,
    required this.onSelectDate,
    required this.onSelectRepeat,
    required this.isRepeat,
    this.date,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant EditAlarmProvider oldWidget) {
    return selectedDays != oldWidget.selectedDays;
  }

  static EditAlarmProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<EditAlarmProvider>();
    assert(provider != null, 'EditAlarmProvider не найден');
    return provider!;
  }
}
