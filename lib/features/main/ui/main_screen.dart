import 'package:alearn/app/app_flow/domain/app_flow_cubit.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/app_text_button.dart';
import 'package:alearn/features/alarm/ui/screens/alarm_screen_new.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return Scaffold(
      key: const Key('root-screen'),
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          AlarmScreen(),
          _WordsTabScreen(),
          _PronunciationTabScreen(),
          _ProfileTabScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: AppContainer(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          borderRadius: 30,
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            elevation: 0,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.alarm_outlined),
                selectedIcon: const Icon(Icons.alarm_rounded),
                label: localizations.nav_alarm,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book_rounded),
                label: localizations.nav_words,
              ),
              NavigationDestination(
                icon: const Icon(Icons.mic_none_rounded),
                selectedIcon: const Icon(Icons.mic_rounded),
                label: localizations.nav_pronunciation,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: localizations.nav_profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordsTabScreen extends StatelessWidget {
  const _WordsTabScreen();

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.words_screen_title)),
      body: SafeArea(
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            final categories = state.categories;
            final totalWords = categories.fold<int>(
              0,
              (sum, category) => sum + category.wordList.length,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: [
                AppEntrance(
                  child: AppContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.words_summary_title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          localizations.words_summary_subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                value: categories.length.toString(),
                                label: localizations.words_categories_metric,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                value: totalWords.toString(),
                                label: localizations.words_total_metric,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (categories.isEmpty)
                  AppEntrance(
                    delay: const Duration(milliseconds: 120),
                    child: AppContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.words_empty_title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            localizations.words_empty_message,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...categories.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppEntrance(
                        delay: Duration(milliseconds: 140 + (entry.key * 50)),
                        child: _CategoryCard(category: entry.value),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PronunciationTabScreen extends StatelessWidget {
  const _PronunciationTabScreen();

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.pronunciation_screen_title)),
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

class _ProfileTabScreen extends StatelessWidget {
  const _ProfileTabScreen();

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
      appBar: AppBar(title: Text(localizations.profile_screen_title)),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      shadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final preview = category.wordList.take(3).toList(growable: false);

    return AppContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                localizations.words_word_count(category.wordList.length),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (preview.isEmpty)
            Text(
              localizations.words_empty_preview,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preview
                  .map(
                    (word) =>
                        Chip(label: Text('${word.enWord} • ${word.ruWord}')),
                  )
                  .toList(growable: false),
            ),
        ],
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
