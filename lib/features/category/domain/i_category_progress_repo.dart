abstract interface class ICategoryProgressRepo {
  Future<Set<int>> getFavoriteIds();

  Future<Set<int>> toggleFavorite(int categoryId);

  Future<Set<int>> getStudiedWordIndexes(int categoryId);

  Future<Set<int>> markWordStudied(int categoryId, int wordIndex);
}
