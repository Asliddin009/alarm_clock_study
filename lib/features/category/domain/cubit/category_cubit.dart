import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends HydratedCubit<CategoryState> {
  CategoryCubit(this.repo) : super(CategoryInitial());
  ICategoryRepo repo;

  Future<void> getCategories() async {
    if (state is CategoryInitial) {}
  }

  @override
  CategoryState? fromJson(Map<String, dynamic> json) {
    if (json.containsKey('listCategory') == false) {
      return null;
    }
    return CategoryDoneState(
      (json['listCategory'] as List<dynamic>)
          .map((e) => CategoryEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic>? toJson(CategoryState state) {
    if (state is CategoryDoneState) {
      return state.toJson();
    }
    return null;
  }
}
