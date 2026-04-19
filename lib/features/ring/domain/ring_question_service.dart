import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';

class RingStudyItem {
  const RingStudyItem({
    required this.sourceText,
    required this.targetText,
    required this.categoryName,
  });

  final String sourceText;
  final String targetText;
  final String categoryName;
}

class RingQuestion {
  const RingQuestion({
    required this.sourceText,
    required this.correctAnswer,
    required this.options,
    required this.categoryName,
  });

  final String sourceText;
  final String correctAnswer;
  final List<String> options;
  final String categoryName;
}

class RingQuestionSession {
  const RingQuestionSession({
    required this.questions,
    required this.previewItems,
  });

  final List<RingQuestion> questions;
  final List<RingStudyItem> previewItems;
}

class RingQuestionService {
  RingQuestionService({required ICategoryRepo categoryRepo})
    : _categoryRepo = categoryRepo;

  final ICategoryRepo _categoryRepo;

  Future<RingQuestion?> buildQuestionForAlarm(AlarmEntity? alarm) async {
    final session = await buildSessionForAlarm(alarm, questionCount: 1);
    if (session == null || session.questions.isEmpty) {
      return null;
    }
    return session.questions.first;
  }

  Future<RingQuestionSession?> buildSessionForAlarm(
    AlarmEntity? alarm, {
    int questionCount = 5,
  }) async {
    final baseCategories = await _categoryRepo.getBaseCategories();
    final fullCategories = await _categoryRepo.getCategories();
    final categories = <CategoryEntity>[...baseCategories, ...fullCategories];
    if (categories.isEmpty) {
      return null;
    }

    final primaryCategories = _selectCategories(
      alarm,
      categories,
      baseCategories,
    );
    final fallbackCategories =
        primaryCategories.any((category) => category.wordList.isNotEmpty)
        ? primaryCategories
        : (baseCategories.any((category) => category.wordList.isNotEmpty)
              ? baseCategories
              : categories);
    final categoryEntries = _buildCategoryEntries(fallbackCategories);
    if (categoryEntries.isEmpty) {
      return null;
    }

    final effectiveCount = questionCount <= 0 ? 1 : questionCount;
    final seed = alarm?.id ?? fallbackCategories.first.id;
    final questions = <RingQuestion>[];
    final previewItems = <RingStudyItem>[];

    for (var index = 0; index < effectiveCount; index++) {
      final entry = categoryEntries[(seed + index) % categoryEntries.length];
      final options = _buildOptions(
        categories: categories,
        correctWord: entry.word,
        seed: seed + index,
      );
      questions.add(
        RingQuestion(
          sourceText: entry.word.ruWord,
          correctAnswer: entry.word.enWord,
          options: options,
          categoryName: entry.category.name,
        ),
      );
      previewItems.add(
        RingStudyItem(
          sourceText: entry.word.ruWord,
          targetText: entry.word.enWord,
          categoryName: entry.category.name,
        ),
      );
    }

    return RingQuestionSession(
      questions: questions,
      previewItems: previewItems,
    );
  }

  List<CategoryEntity> _selectCategories(
    AlarmEntity? alarm,
    List<CategoryEntity> categories,
    List<CategoryEntity> baseCategories,
  ) {
    if (alarm != null && alarm.listCategoryIds.isNotEmpty) {
      final selectedCategories = <CategoryEntity>[];
      for (final categoryId in alarm.listCategoryIds) {
        for (final category in categories) {
          if (category.id == categoryId) {
            selectedCategories.add(category);
          }
        }
      }
      if (selectedCategories.isNotEmpty) {
        return selectedCategories;
      }
    }
    if (baseCategories.isNotEmpty) {
      return baseCategories;
    }
    return categories;
  }

  List<_CategoryWordEntry> _buildCategoryEntries(
    List<CategoryEntity> categories,
  ) {
    final entries = <_CategoryWordEntry>[];
    for (final category in categories) {
      for (final word in category.wordList) {
        entries.add(_CategoryWordEntry(category: category, word: word));
      }
    }
    return entries;
  }

  List<String> _buildOptions({
    required List<CategoryEntity> categories,
    required WordEntity correctWord,
    required int seed,
  }) {
    final pool = <String>{};
    for (final category in categories) {
      for (final word in category.wordList) {
        if (word.enWord != correctWord.enWord) {
          pool.add(word.enWord);
        }
      }
    }

    final distractors = pool.toList(growable: false)..sort();
    final options = <String>[correctWord.enWord];
    for (
      var index = 0;
      index < distractors.length && options.length < 4;
      index++
    ) {
      options.add(distractors[(seed + index) % distractors.length]);
    }
    while (options.length < 4) {
      options.add(correctWord.enWord);
    }

    final rotation = seed % options.length;
    return <String>[...options.skip(rotation), ...options.take(rotation)];
  }
}

class _CategoryWordEntry {
  const _CategoryWordEntry({required this.category, required this.word});

  final CategoryEntity category;
  final WordEntity word;
}
