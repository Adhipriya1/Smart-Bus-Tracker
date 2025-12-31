import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;

  TranslationService._internal();

  final Map<String, OnDeviceTranslator> _translators = {};

  TranslateLanguage _getLanguage(String code) {
    switch (code) {
      case 'hi':
        return TranslateLanguage.hindi;
      case 'mr':
        return TranslateLanguage.marathi;
      case 'ta':
        return TranslateLanguage.tamil;
      case 'en':
      default:
        return TranslateLanguage.english;
    }
  }

  Future<String> translate(String text, String targetLanguageCode) async {
    if (targetLanguageCode == 'en' || text.trim().isEmpty) return text;

    final targetLang = _getLanguage(targetLanguageCode);
    final key = "en_$targetLanguageCode";

    try {
      final modelManager = OnDeviceTranslatorModelManager();

      // Use .bcpCode to convert Enum to String for model management
      if (!await modelManager.isModelDownloaded(targetLang.bcpCode)) {
        debugPrint("Downloading model for $targetLanguageCode...");
        await modelManager.downloadModel(targetLang.bcpCode);
      }

      if (!_translators.containsKey(key)) {
        _translators[key] = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.english,
          targetLanguage: targetLang,
        );
      }

      return await _translators[key]!.translateText(text);
    } catch (e) {
      debugPrint("Translation Error: $e");
      return text; // Fallback to original text
    }
  }

  void dispose() {
    for (var t in _translators.values) {
      t.close();
    }
    _translators.clear();
  }
}
