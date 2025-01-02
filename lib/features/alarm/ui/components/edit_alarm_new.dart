import 'package:alearn/app/ui/ui_kit/app_text_field.dart';
import 'package:alearn/app/ui/ui_kit/weekday_picker.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAlarmScreen extends StatelessWidget {
  const CreateAlarmScreen({super.key});
  static final TextEditingController _dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание будильника'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            //Выбор даты
            AppTextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.datetime,
              controller: _dateTimeController,
              labelText: 'Дата',
            ),
            const DayOfWeekSelector(),
            //создать
            ElevatedButton(
              onPressed: () {
                final List<Weekday> weekdays = [];
                context.read<AlarmBloc>().add(
                      CreateAlarmEvent(
                        dateTime: _getDateTime(),
                        isRepeat: true,
                        weekdays: weekdays,
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _getDateTime() {
    final dateTime = _dateTimeController.text;
    return DateTime.parse(dateTime);
  }
}
