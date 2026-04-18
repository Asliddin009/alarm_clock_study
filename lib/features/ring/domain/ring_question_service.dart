import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';

class RingQuestion {
  const RingQuestion({
    required this.prompt,
    required this.correctAnswer,
    required this.options,
  });

  final String prompt;
  final String correctAnswer;
  final List<String> options;
}

class RingQuestionService {
  RingQuestionService({required ICategoryRepo categoryRepo})
    : _categoryRepo = categoryRepo;

  final ICategoryRepo _categoryRepo;

  Future<RingQuestion?> buildQuestionForAlarm(AlarmEntity? alarm) async {
    final baseCategories = await _categoryRepo.getBaseCategories();
    final fullCategories = await _categoryRepo.getCategories();
    final categories = <CategoryEntity>[...baseCategories, ...fullCategories];
    if (categories.isEmpty) {
      return null;
    }

    final category = _selectCategory(alarm, categories, baseCategories);
    if (category == null || category.wordList.isEmpty) {
      return null;
    }

    final correctWord = category
        .wordList[alarm == null ? 0 : alarm.id % category.wordList.length];
    final options = _buildOptions(
      categories: categories,
      correctWord: correctWord,
      seed: alarm?.id ?? category.id,
    );

    return RingQuestion(
      prompt: 'Выберите перевод слова "${correctWord.ruWord}"',
      correctAnswer: correctWord.enWord,
      options: options,
    );
  }

  CategoryEntity? _selectCategory(
    AlarmEntity? alarm,
    List<CategoryEntity> categories,
    List<CategoryEntity> baseCategories,
  ) {
    if (alarm != null && alarm.listCategoryIds.isNotEmpty) {
      for (final categoryId in alarm.listCategoryIds) {
        for (final category in categories) {
          if (category.id == categoryId) {
            return category;
          }
        }
      }
    }
    if (baseCategories.isNotEmpty) {
      return baseCategories.first;
    }
    return categories.first;
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
