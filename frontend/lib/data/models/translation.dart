class TranslationResult {
  final String translatedText;
  final String sourceLang;

  TranslationResult({
    required this.translatedText,
    required this.sourceLang,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    return TranslationResult(
      translatedText: json['translatedText'],
      sourceLang: json['sourceLang'] ?? 'en',
    );
  }
}

class TranslationHistoryItem {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime createdAt;
  bool isPinned;

  TranslationHistoryItem({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.createdAt,
    this.isPinned = false,
  });

  factory TranslationHistoryItem.fromJson(Map<String, dynamic> json) {
    return TranslationHistoryItem(
      id: json['id'],
      sourceText: json['sourceText'],
      translatedText: json['translatedText'],
      sourceLang: json['sourceLang'],
      targetLang: json['targetLang'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
