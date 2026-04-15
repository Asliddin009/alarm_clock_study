import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
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
    final cubit = CategoryCubit(repo);

    await cubit.getCategories();

    expect(cubit.state, isA<CategoryDoneState>());
    expect(cubit.state.categories.map((category) => category.id), <int>[1, 2]);
  });

  test('emits error state when categories cannot be loaded', () async {
    final cubit = CategoryCubit(FakeCategoryRepo(throwOnGet: true));

    await cubit.getCategories();

    expect(cubit.state, isA<CategoryErrorState>());
  });
}
