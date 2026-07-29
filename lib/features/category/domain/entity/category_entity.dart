import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.name,
    required this.id,
    required this.wordList,
    this.languages = const <String>['ru', 'en'],
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      name: json['name'].toString(),
      id: json['id'] as int,
      wordList: (json['wordList'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (dynamic value) =>
                WordEntity.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      languages: (json['languages'] as List<dynamic>? ?? const <dynamic>['ru', 'en'])
          .map((dynamic value) => value.toString())
          .toList(growable: false),
    );
  }

  final String name;
  final List<WordEntity> wordList;
  final int id;
  final List<String> languages;

  int get phraseCount => wordList.where((word) => word.isPhrase).length;

  int get wordCount => wordList.length - phraseCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'wordList': wordList.map((word) => word.toJson()).toList(growable: false),
      'id': id,
      'languages': languages.toList(growable: false),
    };
  }

  @override
  List<Object?> get props => <Object?>[name, id, wordList, languages];
}
