import 'package:alearn/features/category/data/category_const.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';

class MockCategoryRepo implements ICategoryRepo {
  @override
  Future<List<CategoryEntity>> getCategories() {
    // TODO: implement getCategories
    throw UnimplementedError();
  }

  @override
  List<CategoryEntity> getCategoriesBase() {
    return baseListCategory;
  }

  @override
  Future<CategoryEntity> getCategory(String name) {
    // TODO: implement getCategory
    throw UnimplementedError();
  }

  @override
  String get name => 'MockCategoryRepo';
}
