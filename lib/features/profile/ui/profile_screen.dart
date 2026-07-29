import 'package:alearn/app/app_flow/domain/app_flow_cubit.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/app_text_button.dart';
import 'package:alearn/app/ui/ui_kit/base_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root "Профиль / Настройки" tab (tz.md §6.9): session status, interface
/// language and logout. Sourced from the app-wide [AppFlowCubit] since the
/// profile module has no state of its own yet.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final flowState = context.watch<AppFlowCubit>().state;
    final session = flowState.session;
    final localeCode = flowState.locale?.languageCode ?? 'ru';
    final languageLabel = localeCode == 'en'
        ? localizations.english_language
        : localizations.russian_language;

    return Scaffold(
      appBar: BaseAppBar(
        title: localizations.profile_screen_title,
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
          children: [
            AppEntrance(
              child: AppContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session?.isGuest ?? true
                          ? localizations.profile_guest_title
                          : localizations.profile_authorized_title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      session?.isGuest ?? true
                          ? localizations.profile_guest_subtitle
                          : localizations.profile_authorized_subtitle(
                              session?.displayName ?? session?.email ?? '',
                            ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppEntrance(
              delay: const Duration(milliseconds: 110),
              child: AppContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.profile_preferences_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _ProfileRow(
                      label: localizations.profile_language_label,
                      value: languageLabel,
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(
                      label: localizations.profile_status_label,
                      value: session?.isGuest ?? true
                          ? localizations.profile_guest_status
                          : localizations.profile_authorized_status,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context
                            .read<AppFlowCubit>()
                            .showLanguageSelection(),
                        child: Text(localizations.change_language),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppEntrance(
              delay: const Duration(milliseconds: 180),
              child: AppContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.profile_session_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.profile_session_subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    AppTextButton(
                      key: const Key('root-logout-button'),
                      width: double.infinity,
                      onPressed: () => context.read<AppFlowCubit>().logout(),
                      text: localizations.logout,
                      icon: Icons.logout_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 12),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
