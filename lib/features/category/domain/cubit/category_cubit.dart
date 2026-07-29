import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/i_category_progress_repo.dart';
import 'package:alearn/features/category/domain/i_category_repo.dart';
import 'package:alearn/features/points/domain/i_points_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({
    required this.repo,
    required this.progressRepo,
    required this.pointsRepo,
  }) : super(const CategoryInitial());

  static const int pointsPerWord = 1;
  static const int pointsPerPhrase = 2;

  final ICategoryRepo repo;
  final ICategoryProgressRepo progressRepo;
  final IPointsRepo pointsRepo;

  Future<void> getCategories() async {
    emit(
      CategoryLoadingState(
        categories: state.categories,
        favoriteIds: state.favoriteIds,
        studiedByCategory: state.studiedByCategory,
      ),
    );
    try {
      final baseCategories = await repo.getBaseCategories();
      final fullCategories = await repo.getCategories();
      final categories = _deduplicate([
        ...baseCategories,
        ...fullCategories,
      ]);
      final favoriteIds = await progressRepo.getFavoriteIds();
      final studiedByCategory = <int, Set<int>>{
        for (final category in categories)
          category.id: await progressRepo.getStudiedWordIndexes(category.id),
      };
      emit(
        CategoryDoneState(
          categories,
          favoriteIds: favoriteIds,
          studiedByCategory: studiedByCategory,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        CategoryErrorState(
          message: 'Не удалось загрузить категории. $error',
          categories: state.categories,
          favoriteIds: state.favoriteIds,
          studiedByCategory: state.studiedByCategory,
        ),
      );
    }
  }

  Future<void> toggleFavorite(int categoryId) async {
    final favoriteIds = await progressRepo.toggleFavorite(categoryId);
    emit(
      CategoryDoneState(
        state.categories,
        favoriteIds: favoriteIds,
        studiedByCategory: state.studiedByCategory,
      ),
    );
  }

  /// Marks a word/phrase as studied and awards points the first time it is
  /// learned; repeat views of the same item never re-award points.
  Future<void> markWordStudied(int categoryId, int wordIndex) async {
    final alreadyStudied =
        state.studiedByCategory[categoryId]?.contains(wordIndex) ?? false;
    if (alreadyStudied) {
      return;
    }

    final studiedIndexes = await progressRepo.markWordStudied(
      categoryId,
      wordIndex,
    );
    CategoryEntity? category;
    for (final candidate in state.categories) {
      if (candidate.id == categoryId) {
        category = candidate;
        break;
      }
    }
    final word = category != null && wordIndex < category.wordList.length
        ? category.wordList[wordIndex]
        : null;
    if (word != null) {
      await pointsRepo.addPoints(
        word.isPhrase ? pointsPerPhrase : pointsPerWord,
      );
    }

    emit(
      CategoryDoneState(
        state.categories,
        favoriteIds: state.favoriteIds,
        studiedByCategory: <int, Set<int>>{
          ...state.studiedByCategory,
          categoryId: studiedIndexes,
        },
      ),
    );
  }

  List<CategoryEntity> _deduplicate(List<CategoryEntity> categories) {
    final byId = <int, CategoryEntity>{};
    for (final category in categories) {
      byId[category.id] = category;
    }
    return byId.values.toList(growable: false);
  }
}
