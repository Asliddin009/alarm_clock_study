part of 'category_cubit.dart';

sealed class CategoryState extends Equatable {
  const CategoryState({
    this.categories = const <CategoryEntity>[],
    this.favoriteIds = const <int>{},
    this.studiedByCategory = const <int, Set<int>>{},
  });

  final List<CategoryEntity> categories;
  final Set<int> favoriteIds;
  final Map<int, Set<int>> studiedByCategory;

  bool isFavorite(int categoryId) => favoriteIds.contains(categoryId);

  int studiedCountFor(int categoryId) =>
      studiedByCategory[categoryId]?.length ?? 0;

  @override
  List<Object?> get props => <Object?>[categories, favoriteIds, studiedByCategory];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoadingState extends CategoryState {
  const CategoryLoadingState({
    super.categories,
    super.favoriteIds,
    super.studiedByCategory,
  });
}

final class CategoryErrorState extends CategoryState {
  const CategoryErrorState({
    required this.message,
    super.categories,
    super.favoriteIds,
    super.studiedByCategory,
  });

  final String message;

  @override
  List<Object?> get props => <Object?>[message, categories, favoriteIds, studiedByCategory];
}

final class CategoryDoneState extends CategoryState {
  const CategoryDoneState(
    List<CategoryEntity> categories, {
    super.favoriteIds,
    super.studiedByCategory,
  }) : super(categories: categories);
}
