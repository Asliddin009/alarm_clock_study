import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/base_app_bar.dart';
import 'package:flutter/material.dart';

/// Root "Произношение" tab (tz.md §6.7): a local practice screen without a
/// backend pronunciation analysis yet, so there is no domain/data layer here.
class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return Scaffold(
      appBar: BaseAppBar(
        title: localizations.pronunciation_screen_title,
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
                      localizations.pronunciation_title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.pronunciation_subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppEntrance(
              delay: const Duration(milliseconds: 120),
              child: const _PracticeStepCard(
                icon: Icons.air_rounded,
                titleKey: _PracticeText.breatheTitle,
                bodyKey: _PracticeText.breatheBody,
              ),
            ),
            const SizedBox(height: 12),
            AppEntrance(
              delay: const Duration(milliseconds: 180),
              child: const _PracticeStepCard(
                icon: Icons.hearing_rounded,
                titleKey: _PracticeText.listenTitle,
                bodyKey: _PracticeText.listenBody,
              ),
            ),
            const SizedBox(height: 12),
            AppEntrance(
              delay: const Duration(milliseconds: 240),
              child: const _PracticeStepCard(
                icon: Icons.record_voice_over_rounded,
                titleKey: _PracticeText.repeatTitle,
                bodyKey: _PracticeText.repeatBody,
              ),
            ),
            const SizedBox(height: 16),
            AppEntrance(
              delay: const Duration(milliseconds: 300),
              child: AppContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.pronunciation_phrase_label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      localizations.pronunciation_phrase,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.pronunciation_translation,
                      style: Theme.of(context).textTheme.bodyLarge,
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

enum _PracticeText {
  breatheTitle,
  breatheBody,
  listenTitle,
  listenBody,
  repeatTitle,
  repeatBody,
}

class _PracticeStepCard extends StatelessWidget {
  const _PracticeStepCard({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final _PracticeText titleKey;
  final _PracticeText bodyKey;

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final title = switch (titleKey) {
      _PracticeText.breatheTitle => localizations.pronunciation_breathe_title,
      _PracticeText.listenTitle => localizations.pronunciation_listen_title,
      _PracticeText.repeatTitle => localizations.pronunciation_repeat_title,
      _ => '',
    };
    final body = switch (bodyKey) {
      _PracticeText.breatheBody => localizations.pronunciation_breathe_body,
      _PracticeText.listenBody => localizations.pronunciation_listen_body,
      _PracticeText.repeatBody => localizations.pronunciation_repeat_body,
      _ => '',
    };

    return AppContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(body, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
