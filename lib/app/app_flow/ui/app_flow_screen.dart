import 'package:alearn/app/app_flow/domain/app_flow_cubit.dart';
import 'package:alearn/app/app_flow/domain/app_flow_failure.dart';
import 'package:alearn/app/app_flow/domain/app_flow_state.dart';
import 'package:alearn/app/app_flow/domain/app_flow_step.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_loaded.dart';
import 'package:alearn/app/ui/ui_kit/app_snack_bar.dart';
import 'package:alearn/features/auth/ui/auth_screen.dart';
import 'package:alearn/features/main/ui/main_screen.dart';
import 'package:alearn/features/onboarding/ui/onboarding_screen.dart';
import 'package:alearn/features/onboarding/ui/language_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppFlowScreen extends StatelessWidget {
  const AppFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppFlowCubit, AppFlowState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && current.failure != null,
      listener: (context, state) {
        final localizations = LocalizationHelper.getLocalizations(context);
        final message = switch (state.failure!) {
          AppFlowFailure.invalidCredentials =>
            localizations.invalid_credentials_error,
          AppFlowFailure.unexpected => localizations.unexpected_error,
        };
        AppSnackBar.showError(context, message);
      },
      builder: (context, state) {
        switch (state.step) {
          case AppFlowStep.loading:
            return const AppLoader();
          case AppFlowStep.onboarding:
            return const OnboardingScreen();
          case AppFlowStep.languageSelection:
            return const LanguageSelectionScreen();
          case AppFlowStep.auth:
            return const AuthScreen();
          case AppFlowStep.root:
            return const RootScreen();
        }
      },
    );
  }
}
