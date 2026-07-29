import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/base_app_bar.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/ui/widgets/word_flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({required this.categoryId, super.key});

  final int categoryId;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        CategoryEntity? category;
        for (final candidate in state.categories) {
          if (candidate.id == widget.categoryId) {
            category = candidate;
            break;
          }
        }

        final words = category?.wordList ?? const [];
        final studiedIndexes =
            state.studiedByCategory[widget.categoryId] ?? const <int>{};

        return Scaffold(
          appBar: BaseAppBar(
            title: category?.name ?? '',
            subtitle: words.isEmpty
                ? null
                : localizations.words_progress_count(
                    studiedIndexes.length,
                    words.length,
                  ),
          ),
          body: SafeArea(
            child: words.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        localizations.category_detail_empty,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: _ProgressBar(
                          studied: studiedIndexes.length,
                          total: words.length,
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: words.length,
                          onPageChanged: (index) =>
                              setState(() => _index = index),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                12,
                                20,
                                12,
                              ),
                              child: AppEntrance(
                                key: ValueKey<int>(index),
                                child: WordFlipCard(
                                  word: words[index],
                                  studied: studiedIndexes.contains(index),
                                  onFlipped: () => context
                                      .read<CategoryCubit>()
                                      .markWordStudied(
                                        widget.categoryId,
                                        index,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Text(
                          localizations.category_detail_counter(
                            _index + 1,
                            words.length,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.studied, required this.total});

  final int studied;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total == 0 ? 0.0 : studied / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: isDark
            ? ColorResource.white.withValues(alpha: 0.08)
            : ColorResource.border,
        valueColor: AlwaysStoppedAnimation<Color>(
          isDark ? ColorResource.mint : ColorResource.forest,
        ),
      ),
    );
  }
}
