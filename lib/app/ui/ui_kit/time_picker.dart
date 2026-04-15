import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

Future<TimeOfDay?> showAppTimePickerDialog(
  BuildContext context, {
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (_) => AppTimePickerDialog(initialTime: initialTime),
  );
}

class AppTimePickerDialog extends StatefulWidget {
  const AppTimePickerDialog({
    required this.initialTime,
    super.key,
  });

  final TimeOfDay initialTime;

  @override
  State<AppTimePickerDialog> createState() => _AppTimePickerDialogState();
}

class _AppTimePickerDialogState extends State<AppTimePickerDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Выберите время будильника',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _TimeScrollPicker(
                    value: _hour,
                    minValue: 0,
                    maxValue: 23,
                    onChanged: (value) => setState(() => _hour = value),
                  ),
                ),
                Text(
                  ':',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Expanded(
                  child: _TimeScrollPicker(
                    value: _minute,
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) => setState(() => _minute = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(
                  TimeOfDay(hour: _hour, minute: _minute),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeScrollPicker extends StatelessWidget {
  const _TimeScrollPicker({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return NumberPicker(
      minValue: minValue,
      maxValue: maxValue,
      value: value,
      zeroPad: true,
      infiniteLoop: true,
      onChanged: onChanged,
      textStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey),
      selectedTextStyle: textTheme.headlineSmall,
    );
  }
}
