import 'dart:convert';

import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:flutter/services.dart';

class AssetCategoryRepo implements ICategoryRepo {
  const AssetCategoryRepo();

  static const String _assetPath = 'assets/json/categories.json';

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final categories = await _loadCategories();
    if (categories.length <= 1) {
      return const <CategoryEntity>[];
    }
    return categories.sublist(1);
  }

  @override
  Future<List<CategoryEntity>> getBaseCategories() async {
    final categories = await _loadCategories();
    if (categories.isEmpty) {
      return const <CategoryEntity>[];
    }
    return <CategoryEntity>[categories.first];
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    final categories = await _loadCategories();
    for (final category in categories) {
      if (category.name == name) {
        return category;
      }
    }
    return null;
  }

  Future<List<CategoryEntity>> _loadCategories() async {
    final rawJson = await rootBundle.loadString(_assetPath);
    final rawList = jsonDecode(rawJson) as List<dynamic>;
    return rawList
        .map((dynamic value) => CategoryEntity.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }
}
