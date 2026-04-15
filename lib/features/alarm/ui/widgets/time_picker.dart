import 'package:alearn/app/ui/ui_kit/time_picker.dart';
import 'package:alearn/features/alarm/ui/widgets/edit_alarm_tile.dart';
import 'package:flutter/material.dart';

class AlarmTimePickerField extends StatelessWidget {
  const AlarmTimePickerField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return EditItemWidget(
      title: 'Время',
      leadingIcon: Icons.schedule,
      trailing: Text(
        TimeOfDay.fromDateTime(value).format(context),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () async {
        final pickedTime = await showAppTimePickerDialog(
          context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (pickedTime == null || !context.mounted) {
          return;
        }
        onChanged(
          value.copyWith(
            hour: pickedTime.hour,
            minute: pickedTime.minute,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
        );
      },
    );
  }
}
