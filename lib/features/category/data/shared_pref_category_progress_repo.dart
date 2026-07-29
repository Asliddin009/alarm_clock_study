import 'package:alearn/features/category/domain/i_category_progress_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefCategoryProgressRepo implements ICategoryProgressRepo {
  SharedPrefCategoryProgressRepo(this._sharedPreferences);

  static const String _favoritesKey = 'category_favorite_ids';
  static const String _progressKeyPrefix = 'category_studied_indexes_';

  final SharedPreferences _sharedPreferences;

  @override
  Future<Set<int>> getFavoriteIds() async {
    final stored =
        _sharedPreferences.getStringList(_favoritesKey) ?? const <String>[];
    return stored.map(int.parse).toSet();
  }

  @override
  Future<Set<int>> toggleFavorite(int categoryId) async {
    final favorites = await getFavoriteIds();
    if (favorites.contains(categoryId)) {
      favorites.remove(categoryId);
    } else {
      favorites.add(categoryId);
    }
    await _sharedPreferences.setStringList(
      _favoritesKey,
      favorites.map((id) => id.toString()).toList(growable: false),
    );
    return favorites;
  }

  @override
  Future<Set<int>> getStudiedWordIndexes(int categoryId) async {
    final stored =
        _sharedPreferences.getStringList('$_progressKeyPrefix$categoryId') ??
        const <String>[];
    return stored.map(int.parse).toSet();
  }

  @override
  Future<Set<int>> markWordStudied(int categoryId, int wordIndex) async {
    final studied = await getStudiedWordIndexes(categoryId);
    studied.add(wordIndex);
    await _sharedPreferences.setStringList(
      '$_progressKeyPrefix$categoryId',
      studied.map((index) => index.toString()).toList(growable: false),
    );
    return studied;
  }
}
