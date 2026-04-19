import 'dart:ui';

import 'package:alearn/app/app_flow/domain/app_flow_failure.dart';
import 'package:alearn/app/app_flow/domain/app_flow_step.dart';
import 'package:alearn/features/auth/domain/auth_session.dart';
import 'package:equatable/equatable.dart';

const Object _failureSentinel = Object();
const Object _localeSentinel = Object();
const Object _sessionSentinel = Object();

final class AppFlowState extends Equatable {
  const AppFlowState({
    required this.step,
    required this.isLoading,
    required this.hasCompletedOnboarding,
    this.locale,
    this.session,
    this.failure,
  });

  const AppFlowState.initial()
    : this(
        step: AppFlowStep.loading,
        isLoading: true,
        hasCompletedOnboarding: false,
      );

  final AppFlowStep step;
  final bool isLoading;
  final bool hasCompletedOnboarding;
  final Locale? locale;
  final AuthSession? session;
  final AppFlowFailure? failure;

  AppFlowState copyWith({
    AppFlowStep? step,
    bool? isLoading,
    bool? hasCompletedOnboarding,
    Object? locale = _localeSentinel,
    Object? session = _sessionSentinel,
    Object? failure = _failureSentinel,
  }) {
    return AppFlowState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      locale: identical(locale, _localeSentinel)
          ? this.locale
          : locale as Locale?,
      session: identical(session, _sessionSentinel)
          ? this.session
          : session as AuthSession?,
      failure: identical(failure, _failureSentinel)
          ? this.failure
          : failure as AppFlowFailure?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    step,
    isLoading,
    hasCompletedOnboarding,
    locale,
    session,
    failure,
  ];
}
