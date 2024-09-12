import 'package:alearn/features/alarm/domain/cubit/alarm_cubit.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/alarm_edit_widget.dart';
import 'package:alearn/features/alarm/ui/tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmScreenNew extends StatefulWidget {
  const AlarmScreenNew({super.key});

  @override
  State<AlarmScreenNew> createState() => _AlarmScreenNewState();
}

class _AlarmScreenNewState extends State<AlarmScreenNew>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmCubit, AlarmState>(
      builder: (context, state) {
        if (state is AlarmDoneState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.toString()),
            ),
            body: SafeArea(
              child: ListView.separated(
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
                      //navigateToAlarmScreen(state.listAlarm[index]),
                    },
                    onDismissed: () {
                      // Alarm.stop(state.listAlarm[index].id)
                      //     .then((_) => loadAlarms());
                    },
                  );
                },
              ),
            ),
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

    //if (res != null && res == true) ();
  }
}
