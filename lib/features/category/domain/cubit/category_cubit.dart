import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this.repo) : super(CategoryInitial());
  ICategoryRepo repo;

  Future<void> getCategories() async {
    final baseListCategory = repo.getCategoriesBase();
    emit(CategoryDoneState(baseListCategory));
    final fullListCategory = await repo.getCategories();
    if (fullListCategory.isEmpty) {
      return;
    }
    emit(CategoryDoneState([...baseListCategory, ...fullListCategory]));
  }
}
