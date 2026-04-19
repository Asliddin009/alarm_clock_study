import 'dart:ui';

import 'package:alearn/app/app_flow/domain/app_flow_failure.dart';
import 'package:alearn/app/app_flow/domain/app_flow_state.dart';
import 'package:alearn/app/app_flow/domain/app_flow_step.dart';
import 'package:alearn/app/domain/i_app_preferences_repo.dart';
import 'package:alearn/features/auth/domain/auth_exception.dart';
import 'package:alearn/features/auth/domain/i_auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class AppFlowCubit extends Cubit<AppFlowState> {
  AppFlowCubit({
    required IAuthRepo authRepo,
    required IAppPreferencesRepo appPreferencesRepo,
  }) : _authRepo = authRepo,
       _appPreferencesRepo = appPreferencesRepo,
       super(const AppFlowState.initial());

  final IAuthRepo _authRepo;
  final IAppPreferencesRepo _appPreferencesRepo;

  Future<void> initialize() async {
    emit(
      state.copyWith(step: AppFlowStep.loading, isLoading: true, failure: null),
    );

    final results = await Future.wait<Object?>([
      _appPreferencesRepo.getLocaleCode(),
      _authRepo.restoreSession(),
      _appPreferencesRepo.getHasCompletedOnboarding(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    final localeCode = results[0] as String?;
    final session = results[1] as dynamic;
    final hasCompletedOnboarding = results[2] as bool;
    final locale = localeCode == null ? null : Locale(localeCode);

    emit(
      AppFlowState(
        step: _resolveStep(
          localeCode: localeCode,
          hasSession: session != null,
          hasCompletedOnboarding: hasCompletedOnboarding,
        ),
        isLoading: false,
        hasCompletedOnboarding: hasCompletedOnboarding,
        locale: locale,
        session: session,
      ),
    );
  }

  Future<void> selectLocale(String localeCode) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, failure: null));
    await _appPreferencesRepo.setLocaleCode(localeCode);
    emit(
      state.copyWith(
        isLoading: false,
        locale: Locale(localeCode),
        step: state.session != null
            ? AppFlowStep.root
            : state.hasCompletedOnboarding
            ? AppFlowStep.auth
            : AppFlowStep.onboarding,
      ),
    );
  }

  void showLanguageSelection() {
    emit(
      state.copyWith(
        step: AppFlowStep.languageSelection,
        isLoading: false,
        failure: null,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, failure: null));
    await _appPreferencesRepo.setHasCompletedOnboarding(true);
    emit(
      state.copyWith(
        isLoading: false,
        hasCompletedOnboarding: true,
        step: state.session == null ? AppFlowStep.auth : AppFlowStep.root,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, failure: null));
    try {
      final session = await _authRepo.signIn(email, password);
      emit(
        state.copyWith(
          isLoading: false,
          session: session,
          step: AppFlowStep.root,
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          session: null,
          step: AppFlowStep.auth,
          failure: _mapFailure(error),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isLoading: false,
          session: null,
          step: AppFlowStep.auth,
          failure: AppFlowFailure.unexpected,
        ),
      );
    }
  }

  Future<void> continueAsGuest() async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, failure: null));
    try {
      final session = await _authRepo.continueAsGuest();
      emit(
        state.copyWith(
          isLoading: false,
          session: session,
          step: AppFlowStep.root,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isLoading: false,
          session: null,
          step: AppFlowStep.auth,
          failure: AppFlowFailure.unexpected,
        ),
      );
    }
  }

  Future<void> logout() async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, failure: null));
    await _authRepo.logout();
    emit(
      state.copyWith(
        isLoading: false,
        session: null,
        step: state.hasCompletedOnboarding
            ? AppFlowStep.auth
            : AppFlowStep.onboarding,
      ),
    );
  }

  AppFlowStep _resolveStep({
    required String? localeCode,
    required bool hasSession,
    required bool hasCompletedOnboarding,
  }) {
    if (localeCode == null) {
      return AppFlowStep.languageSelection;
    }
    if (!hasCompletedOnboarding && !hasSession) {
      return AppFlowStep.onboarding;
    }
    if (!hasSession) {
      return AppFlowStep.auth;
    }
    return AppFlowStep.root;
  }

  AppFlowFailure _mapFailure(AuthException error) {
    switch (error.type) {
      case AuthExceptionType.invalidCredentials:
        return AppFlowFailure.invalidCredentials;
      case AuthExceptionType.unsupported:
        return AppFlowFailure.unexpected;
    }
  }
}
