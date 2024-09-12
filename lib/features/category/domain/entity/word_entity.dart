class WordEntity {
  WordEntity({
    required this.ruWord,
    required this.enWord,
    this.examplesRu = const [],
    this.examplesEn = const [],
  });

  factory WordEntity.fromJson(Map<String, dynamic> json) {
    return WordEntity(
      ruWord: json['ruWord'].toString(),
      enWord: json['enWord'].toString(),
      examplesRu: json['examplesRu'].toString().split(','),
      examplesEn: json['examplesEn'].toString().split(','),
    );
  }

  final String ruWord;
  final String enWord;
  final List<String> examplesRu;
  final List<String> examplesEn;

  Map<String, dynamic> toJson() {
    return {
      'ruWord': ruWord,
      'enWord': enWord,
      'examplesRu': examplesRu.toString(),
      'examplesEn': examplesEn.toString(),
    };
  }
}
