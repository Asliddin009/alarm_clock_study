import 'package:equatable/equatable.dart';

class WordEntity extends Equatable {
  const WordEntity({
    required this.ruWord,
    required this.enWord,
    this.examplesRu = const <String>[],
    this.examplesEn = const <String>[],
  });

  factory WordEntity.fromJson(Map<String, dynamic> json) {
    return WordEntity(
      ruWord: json['ruWord'].toString(),
      enWord: json['enWord'].toString(),
      examplesRu: (json['examplesRu'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic value) => value.toString())
          .toList(growable: false),
      examplesEn: (json['examplesEn'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic value) => value.toString())
          .toList(growable: false),
    );
  }

  final String ruWord;
  final String enWord;
  final List<String> examplesRu;
  final List<String> examplesEn;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ruWord': ruWord,
      'enWord': enWord,
      'examplesRu': examplesRu.toList(growable: false),
      'examplesEn': examplesEn.toList(growable: false),
    };
  }

  @override
  List<Object?> get props => <Object?>[ruWord, enWord, examplesRu, examplesEn];
}
