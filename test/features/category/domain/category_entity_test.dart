import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('word entity preserves list serialization', () {
    const word = WordEntity(
      ruWord: 'Код',
      enWord: 'Code',
      examplesRu: <String>['Код пишут каждый день'],
      examplesEn: <String>['We write code every day'],
    );

    final restoredWord = WordEntity.fromJson(word.toJson());

    expect(restoredWord, word);
  });

  test('category entity preserves nested word list', () {
    const category = CategoryEntity(
      id: 1,
      name: 'Для разработчиков',
      wordList: <WordEntity>[
        WordEntity(
          ruWord: 'Разработчик',
          enWord: 'Developer',
          examplesRu: <String>['Разработчик создает приложения'],
          examplesEn: <String>['Developer creates applications'],
        ),
      ],
    );

    final restoredCategory = CategoryEntity.fromJson(category.toJson());

    expect(restoredCategory, category);
  });
}
