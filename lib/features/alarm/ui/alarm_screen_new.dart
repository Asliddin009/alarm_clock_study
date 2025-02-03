import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/alarm_edit_widget.dart';
import 'package:alearn/features/alarm/ui/edit_alarm/edit_alarm_new.dart';
import 'package:alearn/features/alarm/ui/ring_screen/ring_screen.dart';
import 'package:alearn/features/alarm/ui/shortcut_button.dart';
import 'package:alearn/features/alarm/ui/tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmScreenNew extends StatefulWidget {
  const AlarmScreenNew({super.key});

  @override
  State<AlarmScreenNew> createState() => _AlarmScreenNewState();
}

class _AlarmScreenNewState extends State<AlarmScreenNew> with SingleTickerProviderStateMixin {
  StreamSubscription? _ringStreamSubscription;

  @override
  void initState() {
    super.initState();
    _ringStreamSubscription = context.read<AlarmBloc>().getRingStream().listen(navigateToRingScreen);
    context.read<AlarmBloc>().add(AlarmGetAllEvent());
  }

  Future<void> navigateToRingScreen(dynamic value) async {
    final alarmSettings = value as AlarmSettings;
    // log('alarmSettings: $alarmSettings', name: 'navigateToRingScreen');
    // final alarmState = context.read<AlarmBloc>().state as AlarmDoneState;
    // final alarm = alarmState.listAlarm.firstWhere((element) => element.id == alarmSettings.id);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmRingScreen(
          alarmSettings: alarmSettings,
          alarmEntity: AlarmEntity(id: 0, alarmId: 1, time: DateTime.now(), isActive: true),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ringStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        if (state is AlarmDoneState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localization.alarm),
            ),
            body: SafeArea(
              child: state.listAlarm.isEmpty
                  ? Center(
                      child: Text(localization.no_alarms),
                    )
                  : ListView.separated(
                      itemCount: state.listAlarm.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ExampleAlarmTile(
                          key: Key(state.listAlarm[index].id.toString()),
                          title: TimeOfDay(
                            hour: state.listAlarm[index].time.hour,
                            minute: state.listAlarm[index].time.minute,
                          ).format(context),
                          onPressed: () {
                            navigateToAlarmScreen(state.listAlarm[index]);
                          },
                          onDismissed: () {
                            // Alarm.stop(state.listAlarm[index].id)
                            //     .then((_) => loadAlarms());
                          },
                        );
                      },
                    ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ExampleAlarmHomeShortcutButton(refreshAlarms: () {}),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAlarmScreen()));
                    },
                    child: const Icon(Icons.alarm_add_rounded, size: 33),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(state.toString()),
          ),
        );
      },
    );
  }

  Future<void> navigateToAlarmScreen(AlarmEntity alarm) async {
    final res = await showModalBottomSheet<bool?>(
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: AlarmEditWidget(
            alarm: alarm,
          ),
        );
      },
    );

    if (res != null && res == true) {
      if (kDebugMode) {
        print(res);
      }
    }
  }
}
