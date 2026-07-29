import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('loads base and full categories without duplicates', () async {
    final repo = FakeCategoryRepo(
      baseCategories: const <CategoryEntity>[
        CategoryEntity(id: 1, name: 'Base', wordList: []),
      ],
      categories: const <CategoryEntity>[
        CategoryEntity(id: 1, name: 'Base override', wordList: []),
        CategoryEntity(id: 2, name: 'Extra', wordList: []),
      ],
    );
    final cubit = CategoryCubit(
      repo: repo,
      progressRepo: InMemoryCategoryProgressRepo(),
      pointsRepo: InMemoryPointsRepo(),
    );

    await cubit.getCategories();

    expect(cubit.state, isA<CategoryDoneState>());
    expect(cubit.state.categories.map((category) => category.id), <int>[1, 2]);
  });

  test('emits error state when categories cannot be loaded', () async {
    final cubit = CategoryCubit(
      repo: FakeCategoryRepo(throwOnGet: true),
      progressRepo: InMemoryCategoryProgressRepo(),
      pointsRepo: InMemoryPointsRepo(),
    );

    await cubit.getCategories();

    expect(cubit.state, isA<CategoryErrorState>());
  });

  test('toggleFavorite flips favorite status for a category', () async {
    final cubit = CategoryCubit(
      repo: FakeCategoryRepo(),
      progressRepo: InMemoryCategoryProgressRepo(),
      pointsRepo: InMemoryPointsRepo(),
    );

    await cubit.toggleFavorite(1);
    expect(cubit.state.isFavorite(1), isTrue);

    await cubit.toggleFavorite(1);
    expect(cubit.state.isFavorite(1), isFalse);
  });

  test(
    'markWordStudied awards points once per word and once per phrase',
    () async {
      final pointsRepo = InMemoryPointsRepo(0);
      final repo = FakeCategoryRepo(
        baseCategories: const <CategoryEntity>[
          CategoryEntity(
            id: 1,
            name: 'Base',
            wordList: <WordEntity>[
              WordEntity(ruWord: 'Слово', enWord: 'Word'),
              WordEntity(ruWord: 'Доброе утро', enWord: 'Good morning'),
            ],
          ),
        ],
      );
      final cubit = CategoryCubit(
        repo: repo,
        progressRepo: InMemoryCategoryProgressRepo(),
        pointsRepo: pointsRepo,
      );
      await cubit.getCategories();

      await cubit.markWordStudied(1, 0);
      expect(await pointsRepo.getBalance(), 1);
      expect(cubit.state.studiedCountFor(1), 1);

      await cubit.markWordStudied(1, 1);
      expect(await pointsRepo.getBalance(), 3);
      expect(cubit.state.studiedCountFor(1), 2);

      // Studying the same word again must not re-award points.
      await cubit.markWordStudied(1, 0);
      expect(await pointsRepo.getBalance(), 3);
    },
  );
}
