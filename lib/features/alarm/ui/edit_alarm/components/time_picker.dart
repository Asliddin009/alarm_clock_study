import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/app/ui/ui_kit/app_text_button.dart';
import 'package:alearn/app/ui/ui_kit/base_modal_bottom_sheet.dart';
import 'package:alearn/app/ui/ui_kit/time_picker.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/components/edit_alarm_tile.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/edit_alarm_inherited.dart';
import 'package:flutter/material.dart';

class AlarmTimePicker extends StatefulWidget {
  const AlarmTimePicker({super.key});

  @override
  State<AlarmTimePicker> createState() => _AlarmTimePickerState();
}

class _AlarmTimePickerState extends State<AlarmTimePicker> {
  final TextEditingController _timeController = TextEditingController();
  @override
  void initState() {
    _timeController.text = getTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return EditItemWidget(
      title: localization.time,
      parameter: Text(
        _timeController.text,
        style: const TextStyle(
          color: ColorResource.orange500,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () => showBaseModalBottomSheet(
        context: context,
        child: TimePickerWidget(
          date: _timeController.text,
        ),
      ).then(
        (value) {
          if (value != null && value is String) {
            setState(() {
              _timeController.text = value;
            });
            if (!context.mounted) {
              return;
            }
            final newDate = EditAlarmProvider.of(context).date?.copyWith(
                  hour: int.parse(value.split(':').first),
                  minute: int.parse(value.split(':').last),
                );
            if (newDate != null) {
              EditAlarmProvider.of(context).onSelectDate(newDate);
            }
          }
        },
      ),
    );
  }

  static String getTime() {
    final now = DateTime.now();
    return '${now.hour < 10 ? '0${now.hour}' : now.hour}:${now.minute < 10 ? '0${now.minute}' : now.minute}';
  }
}

class TimePickerWidget extends StatefulWidget {
  final String date;
  const TimePickerWidget({
    required this.date,
    super.key,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  int hourStart = 1;
  int minuteStart = 1;
  String textError = '';
  @override
  void initState() {
    hourStart = int.parse(widget.date.split(':')[0]);
    minuteStart = int.parse(widget.date.split(':')[1]);
    super.initState();
  }

  String formatTime(int hour, int minute) {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Container(
              height: 5,
              width: 30,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(color: ColorResource.naturalGrey200, borderRadius: BorderRadius.circular(16)),
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25, left: 16),
                  child: Text(
                    //TODO local
                    'выберите время будильника',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 3,
                    child: TimeScrollWidget(
                      value: hourStart,
                      onChanged: (value) {
                        setState(() {
                          hourStart = value;
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
                      value: minuteStart,
                      onChanged: (value) {
                        setState(() {
                          minuteStart = value;
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
              child: AppTextButton(
                buttonStyle: const ButtonStyle(),
                //TODO local
                text: 'save',
                onPressed: () {
                  final timeRange = formatTime(hourStart, minuteStart);
                  Navigator.of(context).pop(timeRange);
                },
              ),
            ),
            Text(
              textError,
            ),
          ],
        ),
      ),
    );
  }
}
