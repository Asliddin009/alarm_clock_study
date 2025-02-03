import 'dart:developer';

import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/text_field/app_text_field.dart';
import 'package:alearn/app/ui/ui_kit/text_field/input_formatters.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/components/weekday_picker/weekday_picker.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/edit_alarm_inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAlarmScreen extends StatelessWidget {
  const CreateAlarmScreen({super.key});
  static final TextEditingController _dateController = TextEditingController();
  static final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    log('build CreateAlarmScreen');
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
              BaseTextField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.datetime,
                controller: _dateController,
                hintText: localization.date,
                inputFormatters: [
                  DateInputFormatter(),
                ],
              ),
              //Выбор времени
              BaseTextField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.datetime,
                controller: _timeController,
                hintText: localization.time,
                inputFormatters: [
                  DateInputFormatter(),
                ],
              ),
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
      return DateTime.now().add(const Duration(seconds: 5));
      // final dates = _dateController.text.split('.').toList();
      // if (dates.length != 3) {
      //   return null;
      // }
      // return DateTime(int.parse(dates[2]), int.parse(dates[1]), int.parse(dates[0]));
    } on Exception catch (e) {
      log(e.toString(), name: 'CreateAlarmScreen _getDateTime');
      return null;
    }
  }
}
