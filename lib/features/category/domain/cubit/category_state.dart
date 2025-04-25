part of 'category_cubit.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

final class CategoryInitial extends CategoryState {
  @override
  List<Object> get props => [];
}

final class CategoryLoadingState extends CategoryState {}

final class CategoryErrorState extends CategoryState {}

final class CategoryDoneState extends CategoryState {
  const CategoryDoneState(this.listCategory);
  final List<CategoryEntity> listCategory;

  Map<String, dynamic> toJson() {
    return {
      'listCategory': listCategory.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CategoryDoneState{listCategory: $listCategory}';
  }

  @override
  List<Object> get props => [listCategory];
}
