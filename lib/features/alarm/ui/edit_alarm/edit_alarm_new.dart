import 'dart:developer';

import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/components/edit_alarm_tile.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/components/time_picker.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/components/weekday_picker/weekday_picker.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/edit_alarm_inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAlarmScreen extends StatelessWidget {
  const CreateAlarmScreen({super.key});
  static final TextEditingController _dateController = TextEditingController()..text = getDate();

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return EditAlarmInherited(
      child: Scaffold(
        appBar: AppBar(
          title: Text(localization.create_alarm),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 8,
            children: [
              //Выбор даты
              EditItemWidget(
                title: localization.time,
                parameter: Text(
                  _dateController.text,
                  style: const TextStyle(
                    color: ColorResource.orange500,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  pickDate(context).then((value) {
                    if (value != null) {
                      _dateController.text = '${value.day < 10 ? '0${value.day}' : value.day}.${value.month < 10 ? '0${value.month}' : value.month}.${value.year}';
                    }
                  });
                },
              ),
              //Выбор времени
              const AlarmTimePicker(),
              //Дни недели
              const DayOfWeekSelector(),
              //создать
              ElevatedButton(
                onPressed: () {
                  final List<Weekday> weekdays = [];
                  final date = _getDateTime();

                  if (date == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Дата не выбрана')));
                    return;
                  }
                  context.read<AlarmBloc>().add(
                        AlarmCreateEvent(
                          dateTime: date,
                          isRepeat: true,
                          weekdays: weekdays,
                          listCategoryId: [],
                        ),
                      );
                  Navigator.pop(context);
                },
                //local
                child: const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _getDateTime() {
    try {
      return DateTime.now().add(const Duration(seconds: 10));
    } on Exception catch (e) {
      log(e.toString(), name: 'CreateAlarmScreen _getDateTime');
      return null;
    }
  }

  static String getDate() {
    final now = DateTime.now();
    return '${now.day < 10 ? '0${now.day}' : now.day}.${now.month < 10 ? '0${now.month}' : now.month}.${now.year}';
  }
}

Future<DateTime?> pickDate(BuildContext context) async {
  final DateTime currentDate = DateTime.now();

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: currentDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
  return selectedDate;
}
