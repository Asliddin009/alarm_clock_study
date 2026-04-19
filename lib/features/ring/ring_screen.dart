import 'dart:async';

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

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({
    required this.alarmId,
    this.questionService,
    super.key,
  });

  final int alarmId;
  final RingQuestionService? questionService;

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  RingQuestionSession? _session;
  bool _isLoading = true;
  bool _isAdvancing = false;
  bool _didLoadSession = false;
  int _currentIndex = 0;
  int _pointsBalance = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadSession) {
      return;
    }
    _didLoadSession = true;
    unawaited(_loadSession());
  }

  Future<void> _loadSession() async {
    final appDependencies = AppDependenciesScope.of(context);
    final alarm = _findAlarm(context.read<AlarmBloc>().state.alarms);
    final resolvedQuestionService =
        widget.questionService ?? appDependencies.ringQuestionService;
    final session = await resolvedQuestionService.buildSessionForAlarm(alarm);
    final pointsBalance = await appDependencies.pointsRepo.getBalance();

    if (!mounted) {
      return;
    }
    setState(() {
      _session = session;
      _pointsBalance = pointsBalance;
      _isLoading = false;
    });
  }

  AlarmEntity? _findAlarm(List<AlarmEntity> alarms) {
    for (final alarm in alarms) {
      if (alarm.id == widget.alarmId) {
        return alarm;
      }
    }
    return null;
  }

  Future<void> _handleAnswer(String option) async {
    final session = _session;
    if (session == null || _isAdvancing) {
      return;
    }

    final localization = LocalizationHelper.getLocalizations(context);
    final question = session.questions[_currentIndex];
    if (option != question.correctAnswer) {
      setState(() => _isAdvancing = true);
      AppSnackBar.showInfo(context, localization.ring_wrong_answer_delay);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) {
        return;
      }
      _advanceOrFinish(correct: false);
      return;
    }

    _advanceOrFinish(correct: true);
  }

  Future<void> _advanceOrFinish({required bool correct}) async {
    final session = _session;
    if (session == null) {
      return;
    }

    final hasMoreQuestions = _currentIndex < session.questions.length - 1;
    if (hasMoreQuestions) {
      setState(() {
        _currentIndex += 1;
        _isAdvancing = false;
      });
      return;
    }

    await _dismissCurrentAlarm();
  }

  Future<void> _dismissCurrentAlarm() async {
    final appDependencies = AppDependenciesScope.of(context);
    await appDependencies.alarmService.dismissRingingAlarm(widget.alarmId);
    if (!mounted) {
      return;
    }
    context.read<AlarmBloc>().add(const AlarmRefreshRequested());
    Navigator.of(context).pop();
  }

  Future<void> _disableByPoints() async {
    final localization = LocalizationHelper.getLocalizations(context);
    final appDependencies = AppDependenciesScope.of(context);

    try {
      final nextBalance = await appDependencies.pointsRepo.spendPoints(10);
      if (!mounted) {
        return;
      }
      setState(() => _pointsBalance = nextBalance);
      await _dismissCurrentAlarm();
      if (!mounted) {
        return;
      }
      AppSnackBar.showSuccess(context, localization.alarm_disabled_success);
    } on StateError {
      AppSnackBar.showInfo(context, localization.points_insufficient);
    }
  }

  Future<void> _snoozeByPoints() async {
    final localization = LocalizationHelper.getLocalizations(context);
    final alarm = _findAlarm(context.read<AlarmBloc>().state.alarms);
    if (alarm == null) {
      await _dismissCurrentAlarm();
      return;
    }

    final appDependencies = AppDependenciesScope.of(context);
    try {
      final nextBalance = await appDependencies.pointsRepo.spendPoints(2);
      await appDependencies.alarmService.updateAlarm(
        alarm.copyWith(time: alarm.time.add(const Duration(minutes: 10))),
      );
      await appDependencies.alarmService.dismissRingingAlarm(widget.alarmId);
      if (!mounted) {
        return;
      }
      setState(() => _pointsBalance = nextBalance);
      context.read<AlarmBloc>().add(const AlarmRefreshRequested());
      Navigator.of(context).pop();
      AppSnackBar.showSuccess(context, localization.alarm_postponed_success);
    } on StateError {
      AppSnackBar.showInfo(context, localization.points_insufficient);
    } on Object catch (error) {
      AppSnackBar.showError(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final alarm = _findAlarm(context.watch<AlarmBloc>().state.alarms);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.wake_up_title)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _session == null || _session!.questions.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: AppEntrance(
                  child: AppContainer(
                    padding: const EdgeInsets.all(18),
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
                        Text(localizations.quiz_unavailable),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: _dismissCurrentAlarm,
                          child: Text(localizations.stop_alarm),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: AppEntrance(
                  child: AppContainer(
                    padding: const EdgeInsets.all(18),
                    child: _QuizContent(
                      alarm: alarm,
                      session: _session!,
                      currentIndex: _currentIndex,
                      pointsBalance: _pointsBalance,
                      isBusy: _isAdvancing,
                      onAnswer: _handleAnswer,
                      onDisableByPoints: _disableByPoints,
                      onSnoozeByPoints: _snoozeByPoints,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent({
    required this.alarm,
    required this.session,
    required this.currentIndex,
    required this.pointsBalance,
    required this.isBusy,
    required this.onAnswer,
    required this.onDisableByPoints,
    required this.onSnoozeByPoints,
  });

  final AlarmEntity? alarm;
  final RingQuestionSession session;
  final int currentIndex;
  final int pointsBalance;
  final bool isBusy;
  final ValueChanged<String> onAnswer;
  final VoidCallback onDisableByPoints;
  final VoidCallback onSnoozeByPoints;

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final question = session.questions[currentIndex];
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 720;
        final sectionSpacing = isCompactHeight ? 16.0 : 20.0;
        final optionSpacing = isCompactHeight ? 10.0 : 12.0;
        final optionWidth = (constraints.maxWidth - optionSpacing) / 2;
        final answerButtonStyle = ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isCompactHeight ? 12 : 14,
          ),
          textStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                alarm == null
                    ? localizations.ring_alarm_missing
                    : localizations.ring_alarm_label(alarm!.formattedTime),
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: isCompactHeight ? 8 : 12),
              Text(
                localizations.ring_progress(
                  currentIndex + 1,
                  session.questions.length,
                ),
                style: theme.textTheme.labelLarge,
              ),
              SizedBox(height: isCompactHeight ? 12 : 16),
              LinearProgressIndicator(
                value: (currentIndex + 1) / session.questions.length,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
              SizedBox(height: sectionSpacing),
              Text(
                localizations.ring_question_prompt(question.sourceText),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: isCompactHeight ? 22 : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${localizations.alarm_preview_category_label}: ${question.categoryName}',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: sectionSpacing),
              Wrap(
                spacing: optionSpacing,
                runSpacing: optionSpacing,
                children: question.options.asMap().entries.map((entry) {
                  return SizedBox(
                    width: optionWidth,
                    child: AppEntrance(
                      delay: Duration(milliseconds: 80 + (entry.key * 40)),
                      child: ElevatedButton(
                        style: answerButtonStyle,
                        onPressed: isBusy ? null : () => onAnswer(entry.value),
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sectionSpacing),
              Text(
                localizations.ring_points_title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '${localizations.alarm_points_value(pointsBalance)}. ${localizations.ring_points_subtitle}',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: isCompactHeight ? 12 : 16),
              OutlinedButton(
                onPressed: pointsBalance >= 2 && !isBusy
                    ? onSnoozeByPoints
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isCompactHeight ? 12 : 14,
                  ),
                ),
                child: Text(
                  localizations.ring_snooze_now,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pointsBalance >= 10 && !isBusy
                    ? onDisableByPoints
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isCompactHeight ? 12 : 14,
                  ),
                ),
                child: Text(
                  localizations.ring_disable_now,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
