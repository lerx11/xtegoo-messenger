import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'api_service.dart';
import '../models/translation.dart';

class TranslateService {
  final ApiService _api;
  final Box _translationsBox = Hive.box('translations');

  TranslateService(this._api);

  Future<TranslationResult> translate(String text, String targetLang, {String? sourceLang}) async {
    final cacheKey = '${text}_$targetLang';

    final cached = _translationsBox.get(cacheKey);
    if (cached != null) {
      return TranslationResult(
        translatedText: cached['translatedText'],
        sourceLang: cached['sourceLang'],
      );
    }

    final response = await _api.post('/translate/translate', data: {
      'text': text,
      'targetLang': targetLang,
      if (sourceLang != null) 'sourceLang': sourceLang,
    });

    final result = TranslationResult.fromJson(response.data);

    _translationsBox.put(cacheKey, {
      'translatedText': result.translatedText,
      'sourceLang': result.sourceLang,
    });

    return result;
  }

  Future<List<dynamic>> getLanguages() async {
    final response = await _api.get('/translate/languages');
    return response.data;
  }

  Future<String> detectLanguage(String text) async {
    final response = await _api.post('/translate/detect', data: {'text': text});
    return response.data['language'];
  }

  Future<List<TranslationHistoryItem>> getHistory() async {
    try {
      final response = await _api.get('/translate/history');
      return (response.data as List)
          .map((e) => TranslationHistoryItem.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<TranslationHistoryItem> getLocalHistory() {
    final items = <TranslationHistoryItem>[];
    for (var i = 0; i < _translationsBox.length; i++) {
      final key = _translationsBox.keyAt(i);
      final value = _translationsBox.get(key);
      final parts = (key as String).split('_');
      if (parts.length >= 2) {
        final sourceText = parts.sublist(0, parts.length - 1).join('_');
        final targetLang = parts.last;
        items.add(
          TranslationHistoryItem(
            id: key,
            sourceText: sourceText,
            translatedText: value['translatedText'],
            sourceLang: value['sourceLang'],
            targetLang: targetLang,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    return items.reversed.take(50).toList();
  }
}

final translateServiceProvider = Provider<TranslateService>((ref) {
  final apiService = ApiService();
  return TranslateService(apiService);
});
