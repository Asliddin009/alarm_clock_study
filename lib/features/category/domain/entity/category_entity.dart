import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.name,
    required this.id,
    required this.wordList,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      name: json['name'].toString(),
      id: json['id'] as int,
      wordList: (json['wordList'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic value) => WordEntity.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String name;
  final List<WordEntity> wordList;
  final int id;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'wordList': wordList.map((word) => word.toJson()).toList(growable: false),
      'id': id,
    };
  }

  @override
  List<Object?> get props => <Object?>[name, id, wordList];
}
