import 'package:alearn/features/category/domain/entity/category_entity.dart';

abstract interface class ICategoryRepo {
  String get name;

  Future<List<CategoryEntity>> getCategories();
  List<CategoryEntity> getCategoriesBase();
  Future<CategoryEntity> getCategory(String name);
}
