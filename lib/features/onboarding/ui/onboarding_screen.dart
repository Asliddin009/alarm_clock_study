import 'package:alearn/app/app_flow/domain/app_flow_cubit.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);
    final pages = <_OnboardingPageData>[
      _OnboardingPageData(
        animationAsset: 'assets/lottie/onboarding_alarm.json',
        title: localizations.onboarding_alarm_title,
        description: localizations.onboarding_alarm_description,
      ),
      _OnboardingPageData(
        animationAsset: 'assets/lottie/onboarding_words.json',
        title: localizations.onboarding_words_title,
        description: localizations.onboarding_words_description,
      ),
      _OnboardingPageData(
        animationAsset: 'assets/lottie/onboarding_voice.json',
        title: localizations.onboarding_voice_title,
        description: localizations.onboarding_voice_description,
      ),
    ];

    final isLastPage = _pageIndex == pages.length - 1;

    return Scaffold(
      key: const Key('onboarding-screen'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('onboarding-skip-button'),
                  onPressed: () =>
                      context.read<AppFlowCubit>().completeOnboarding(),
                  child: Text(localizations.onboarding_skip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  key: const Key('onboarding-page-view'),
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return AppEntrance(
                      key: ValueKey<String>('onboarding-page-$index'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: AppContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Lottie.asset(
                                      page.animationAsset,
                                      repeat: true,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _pageIndex == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _pageIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('onboarding-primary-button'),
                  onPressed: () {
                    if (isLastPage) {
                      context.read<AppFlowCubit>().completeOnboarding();
                      return;
                    }
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Text(
                    isLastPage
                        ? localizations.onboarding_start
                        : localizations.onboarding_next,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _OnboardingPageData {
  const _OnboardingPageData({
    required this.animationAsset,
    required this.title,
    required this.description,
  });

  final String animationAsset;
  final String title;
  final String description;
}
