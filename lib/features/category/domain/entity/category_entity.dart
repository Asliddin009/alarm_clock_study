import 'package:alearn/features/category/domain/entity/word_entity.dart';

class CategoryEntity {
  CategoryEntity({
    required this.name,
    required this.id,
    required this.wordList,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      name: json['name'].toString(),
      wordList: (json['wordList'] as List<dynamic>).map((json) => WordEntity.fromJson(json as Map<String, dynamic>))
          as List<WordEntity>,
      id: json['id'],
    );
  }

  final String name;
  final List<WordEntity> wordList;
  final int id;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'wordList': wordList.map((e) => e.toJson()),
      'id': id,
    };
  }
}
