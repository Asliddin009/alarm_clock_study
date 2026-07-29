import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/base_app_bar.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/ui/category_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root "Слова и фразы" tab: category overview plus quick access to study
/// any category's flashcards (tz.md §6.6).
class WordsScreen extends StatelessWidget {
  const WordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return Scaffold(
      appBar: BaseAppBar(
        title: localizations.words_screen_title,
        showBackButton: false,
      ),
      body: SafeArea(
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            final categories = state.categories;
            final totalWords = categories.fold<int>(
              0,
              (sum, category) => sum + category.wordList.length,
            );
            final favorites = categories
                .where((category) => state.isFavorite(category.id))
                .toList(growable: false);
            final others = categories
                .where((category) => !state.isFavorite(category.id))
                .toList(growable: false);

            return RefreshIndicator(
              onRefresh: () => context.read<CategoryCubit>().getCategories(),
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
                  if (state is CategoryErrorState)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppContainer(
                        padding: const EdgeInsets.all(18),
                        borderColor: ColorResource.danger.withValues(
                          alpha: 0.3,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: ColorResource.danger,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.message,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (categories.isEmpty && state is! CategoryLoadingState)
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
                  else ...[
                    if (favorites.isNotEmpty) ...[
                      _SectionHeader(
                        title: localizations.words_favorites_section_title,
                      ),
                      const SizedBox(height: 10),
                      ...favorites.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppEntrance(
                            delay: Duration(milliseconds: 100 + (entry.key * 50)),
                            child: _CategoryCard(category: entry.value),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      _SectionHeader(
                        title:
                            localizations.words_all_categories_section_title,
                      ),
                      const SizedBox(height: 10),
                    ],
                    ...others.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppEntrance(
                          delay: Duration(milliseconds: 140 + (entry.key * 50)),
                          child: _CategoryCard(category: entry.value),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: ColorResource.muted),
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
    final state = context.watch<CategoryCubit>().state;
    final isFavorite = state.isFavorite(category.id);
    final studiedCount = state.studiedCountFor(category.id);
    final total = category.wordList.length;
    final progress = total == 0 ? 0.0 : studiedCount / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = category.wordList.take(3).toList(growable: false);

    return AppContainer(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CategoryDetailScreen(categoryId: category.id),
          ),
        ),
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
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => context
                      .read<CategoryCubit>()
                      .toggleFavorite(category.id),
                  tooltip: isFavorite
                      ? localizations.words_favorite_remove_label
                      : localizations.words_favorite_add_label,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFavorite
                        ? (isDark ? ColorResource.mint : ColorResource.forest)
                        : ColorResource.muted,
                  ),
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? ColorResource.white.withValues(alpha: 0.08)
                      : ColorResource.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? ColorResource.mint : ColorResource.forest,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localizations.words_progress_count(studiedCount, total),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
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
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CategoryDetailScreen(categoryId: category.id),
                  ),
                ),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                label: Text(localizations.words_study_action),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
