import 'dart:math' as math;

import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/localization/app_localizations.dart';
import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:flutter/material.dart';

class WordFlipCard extends StatefulWidget {
  const WordFlipCard({
    required this.word,
    required this.studied,
    required this.onFlipped,
    super.key,
  });

  final WordEntity word;
  final bool studied;
  final VoidCallback onFlipped;

  @override
  State<WordFlipCard> createState() => _WordFlipCardState();
}

class _WordFlipCardState extends State<WordFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  bool _showBack = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_showBack && !widget.studied) {
      widget.onFlipped();
    }
    setState(() => _showBack = !_showBack);
    if (_showBack) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final showingBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateY(angle),
            child: showingBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      isBack: true,
                      word: widget.word,
                      studied: widget.studied,
                      localizations: localizations,
                    ),
                  )
                : _CardFace(
                    isBack: false,
                    word: widget.word,
                    studied: widget.studied,
                    localizations: localizations,
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.isBack,
    required this.word,
    required this.studied,
    required this.localizations,
  });

  final bool isBack;
  final WordEntity word;
  final bool studied;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final examples = isBack ? word.examplesEn : word.examplesRu;
    final typeLabel = word.isPhrase
        ? localizations.category_word_type_phrase
        : localizations.category_word_type_word;

    return AppContainer(
      height: 220,
      padding: const EdgeInsets.all(24),
      color: isBack
          ? (isDark
                ? ColorResource.forestAccent.withValues(alpha: 0.22)
                : ColorResource.mint.withValues(alpha: 0.22))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(label: typeLabel),
              const Spacer(),
              if (studied)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: isDark ? ColorResource.mint : ColorResource.forest,
                ),
            ],
          ),
          const Spacer(),
          Text(
            isBack ? word.enWord : word.ruWord,
            style: theme.textTheme.headlineMedium,
          ),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              examples.first,
              style: theme.textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          Text(
            localizations.category_detail_flip_hint,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? ColorResource.white.withValues(alpha: 0.08)
            : ColorResource.forest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isDark ? ColorResource.white : ColorResource.forest,
        ),
      ),
    );
  }
}
