import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter/material.dart';

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    required this.selectedWeekdays,
    required this.onChanged,
    super.key,
  });

  final List<Weekday> selectedWeekdays;
  final ValueChanged<List<Weekday>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Weekday.values
          .map((weekday) {
            final isSelected = selectedWeekdays.contains(weekday);
            return FilterChip(
              label: Text(weekday.shortLabel),
              selected: isSelected,
              onSelected: (_) {
                final updated = <Weekday>[...selectedWeekdays];
                if (isSelected) {
                  updated.remove(weekday);
                } else {
                  updated.add(weekday);
                }
                onChanged(updated);
              },
            );
          })
          .toList(growable: false),
    );
  }
}
