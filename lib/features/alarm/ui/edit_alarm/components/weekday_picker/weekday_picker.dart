import 'dart:developer';

import 'package:alearn/features/alarm/ui/edit_alarm/components/weekday_picker/weekday_type.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/edit_alarm_inherited.dart';
import 'package:flutter/material.dart';

const List<WeekdayType> daysOfWeek = [
  WeekdayType.monday,
  WeekdayType.tuesday,
  WeekdayType.wednesday,
  WeekdayType.thursday,
  WeekdayType.friday,
  WeekdayType.saturday,
  WeekdayType.sunday,
];

class DayOfWeekSelector extends StatefulWidget {
  const DayOfWeekSelector({super.key});

  @override
  DayOfWeekSelectorState createState() => DayOfWeekSelectorState();
}

class DayOfWeekSelectorState extends State<DayOfWeekSelector> {
  List<WeekdayType> selectedDay = []; // Переменная для хранения выбранного дня
  // Список дней недели

  @override
  Widget build(BuildContext context) {
    log('build DayOfWeekSelector');
    final selectedDay = EditAlarmProvider.of(context).selectedDays;
    return Wrap(
      spacing: 8,
      children: daysOfWeek.map((day) {
        return WrapContainer(
          text: day.getShortName(),
          selected: selectedDay.contains(day),
          onTap: () {
            setState(() {
              if (selectedDay.contains(day)) {
                selectedDay.remove(day);
              } else {
                selectedDay.add(day);
              }
            });
            EditAlarmProvider.of(context).onSelecteWeekday(
              day,
            );
          },
        );
      }).toList(),
    );
  }
}

class WrapContainer extends StatelessWidget {
  const WrapContainer({
    required this.text,
    required this.selected,
    super.key,
    this.onTap,
    this.height,
    this.width,
  });
  final String text;
  final bool selected;
  final void Function()? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 40,
        width: width ?? 40,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
