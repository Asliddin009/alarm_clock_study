part of 'category_cubit.dart';

sealed class CategoryState extends Equatable {
  const CategoryState({this.categories = const <CategoryEntity>[]});

  final List<CategoryEntity> categories;

  @override
  List<Object?> get props => <Object?>[categories];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoadingState extends CategoryState {
  const CategoryLoadingState({super.categories});
}

final class CategoryErrorState extends CategoryState {
  const CategoryErrorState({required this.message, super.categories});

  final String message;

  @override
  List<Object?> get props => <Object?>[message, categories];
}

final class CategoryDoneState extends CategoryState {
  const CategoryDoneState(List<CategoryEntity> categories)
    : super(categories: categories);
}
