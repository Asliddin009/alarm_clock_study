import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/app_snack_bar.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/screens/edit_alarm_new.dart';
import 'package:alearn/features/alarm/ui/widgets/shortcut_button.dart';
import 'package:alearn/features/alarm/ui/widgets/tile.dart';
import 'package:alearn/features/ring/ring_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  StreamSubscription<AlarmSettings>? _ringStreamSubscription;

  @override
  void initState() {
    super.initState();
    _ringStreamSubscription = context.read<AlarmBloc>().ringStream.listen(
      _openRingScreen,
    );
  }

  Future<void> _openRingScreen(AlarmSettings alarmSettings) async {
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlarmRingScreen(alarmId: alarmSettings.id),
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
    return BlocConsumer<AlarmBloc, AlarmState>(
      listener: (context, state) {
        if (state is AlarmErrorState) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final alarms = state.alarms;
        final isLoading = state is AlarmLoadingState && alarms.isEmpty;

        return Scaffold(
          appBar: AppBar(title: Text(localization.alarm)),
          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : alarms.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AppEntrance(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: AppContainer(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.no_alarms,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  localization.alarm_empty_subtitle,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                    itemCount: alarms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      return AppEntrance(
                        delay: Duration(milliseconds: 60 + (index * 40)),
                        child: AlarmTile(
                          alarm: alarm,
                          onPressed: () => _openEditScreen(alarm),
                          onDismissed: () {
                            context.read<AlarmBloc>().add(
                              AlarmDeleteRequested(alarm.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ExampleAlarmHomeShortcutButton(),
                FloatingActionButton(
                  heroTag: 'create-alarm',
                  onPressed: () => _openEditScreen(null),
                  child: const Icon(Icons.alarm_add_rounded, size: 32),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Future<void> _openEditScreen(AlarmEntity? alarm) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateAlarmScreen(initialAlarm: alarm),
      ),
    );
  }
}
