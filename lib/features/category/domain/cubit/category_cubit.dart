import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this.repo) : super(const CategoryInitial());

  final ICategoryRepo repo;

  Future<void> getCategories() async {
    emit(CategoryLoadingState(categories: state.categories));
    try {
      final baseCategories = await repo.getBaseCategories();
      final fullCategories = await repo.getCategories();
      emit(
        CategoryDoneState(_deduplicate([...baseCategories, ...fullCategories])),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        CategoryErrorState(
          message: 'Не удалось загрузить категории. $error',
          categories: state.categories,
        ),
      );
    }
  }

  List<CategoryEntity> _deduplicate(List<CategoryEntity> categories) {
    final byId = <int, CategoryEntity>{};
    for (final category in categories) {
      byId[category.id] = category;
    }
    return byId.values.toList(growable: false);
  }
}
