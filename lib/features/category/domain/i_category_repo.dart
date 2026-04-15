import 'package:alearn/features/category/domain/entity/category_entity.dart';

abstract interface class ICategoryRepo {
  Future<List<CategoryEntity>> getCategories();

  Future<List<CategoryEntity>> getBaseCategories();

  Future<CategoryEntity?> getCategoryByName(String name);
}
