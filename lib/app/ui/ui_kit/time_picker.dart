import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({required this.hour, required this.minute, super.key});
  final int hour;
  final int minute;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  int hour = 0;
  int minute = 0;

  @override
  void initState() {
    super.initState();
    hour = widget.hour;
    minute = widget.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorResource.naturalGrey850,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Выберите время будильника',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 3,
                  child: TimeScrollWidget(
                    value: hour,
                    onChanged: (value) {
                      setState(() {
                        hour = value;
                      });
                    },
                    minValue: 0,
                    maxValue: 23,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      ':',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TimeScrollWidget(
                    value: minute,
                    onChanged: (value) {
                      setState(() {
                        minute = value;
                      });
                    },
                    minValue: 0,
                    maxValue: 59,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 10),
            child: ElevatedButton(
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop(
                  DateTime.now().copyWith(
                    hour: hour,
                    minute: minute,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimeScrollWidget extends StatelessWidget {
  const TimeScrollWidget({
    required this.value,
    required this.onChanged,
    required this.minValue,
    required this.maxValue,
    this.step = 1,
    super.key,
  });
  final int step;
  final int value;
  final Function(int) onChanged;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
        minWidth: 100,
        maxHeight: 150,
        maxWidth: 150,
      ),
      child: Stack(
        children: [
          Align(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 100,
                maxHeight: 60,
                maxWidth: 120,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorResource.naturalGrey200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Align(
            child: NumberPicker(
              step: step,
              minValue: minValue,
              maxValue: maxValue,
              value: value,
              zeroPad: true,
              infiniteLoop: true,
              onChanged: onChanged,
              textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: ColorResource.naturalGrey700),
              selectedTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
