import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/app_snack_bar.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmRingScreen extends StatelessWidget {
  const AlarmRingScreen({
    required this.alarmId,
    this.questionService,
    super.key,
  });

  final int alarmId;
  final RingQuestionService? questionService;

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final alarm = _findAlarm(context.watch<AlarmBloc>().state.alarms);
    final resolvedQuestionService =
        questionService ?? AppDependenciesScope.of(context).ringQuestionService;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.wake_up_title)),
      body: SafeArea(
        child: FutureBuilder<RingQuestion?>(
          future: resolvedQuestionService.buildQuestionForAlarm(alarm),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final question = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: AppEntrance(
                child: AppContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        alarm == null
                            ? localizations.ring_alarm_missing
                            : localizations.ring_alarm_label(
                                alarm.formattedTime,
                              ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (question == null)
                        Text(localizations.quiz_unavailable)
                      else ...[
                        Text(
                          question.prompt,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ...question.options.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppEntrance(
                              delay: Duration(
                                milliseconds: 80 + (entry.key * 45),
                              ),
                              child: ElevatedButton(
                                onPressed: () => _handleAnswer(
                                  context,
                                  option: entry.value,
                                  correctAnswer: question.correctAnswer,
                                ),
                                child: Text(entry.value),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => _stopAlarm(context),
                        child: Text(localizations.stop_alarm),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AlarmEntity? _findAlarm(List<AlarmEntity> alarms) {
    for (final alarm in alarms) {
      if (alarm.id == alarmId) {
        return alarm;
      }
    }
    return null;
  }

  void _handleAnswer(
    BuildContext context, {
    required String option,
    required String correctAnswer,
  }) {
    if (option != correctAnswer) {
      final localizations = LocalizationHelper.getLocalizations(context);
      AppSnackBar.showInfo(context, localizations.wrong_answer);
      return;
    }
    _stopAlarm(context);
  }

  void _stopAlarm(BuildContext context) {
    context.read<AlarmBloc>().add(AlarmDeleteRequested(alarmId));
    Navigator.of(context).pop();
  }
}
