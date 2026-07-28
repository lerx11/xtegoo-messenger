import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/core.dart';
import '../../../data/services/translate_service.dart';

class TranslatorScreen extends ConsumerStatefulWidget {
  final bool fullScreen;

  const TranslatorScreen({super.key, this.fullScreen = false});

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final _sourceController = TextEditingController();
  String _translatedText = '';
  String _sourceLang = 'auto';
  String _targetLang = 'ru';
  bool _isTranslating = false;
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  DateTime? _lastInput;

  final List<Map<String, String>> _languages = const [
    {'code': 'auto', 'name': 'Авто', 'flag': '🌐'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  String _getFlag(String code) {
    return _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'flag': '🌐'},
    )['flag']!;
  }

  String _getLangName(String code) {
    return _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': code},
    )['name']!;
  }

  void _swapLanguages() {
    if (_sourceLang == 'auto') return;
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _sourceController.text = _translatedText;
      _translatedText = '';
    });
    if (_sourceController.text.isNotEmpty) {
      _translate();
    }
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) {
      setState(() => _translatedText = '');
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translateService = ref.read(translateServiceProvider);
      final result = await translateService.translate(
        _sourceController.text,
        _targetLang,
        sourceLang: _sourceLang == 'auto' ? null : _sourceLang,
      );
      setState(() {
        _translatedText = result.translatedText;
        if (_sourceLang == 'auto') {
          // _sourceLang = result.sourceLang;
        }
      });
    } catch (e) {
      setState(() => _translatedText = 'Ошибка перевода');
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  void _onTextChanged(String value) {
    _lastInput = DateTime.now();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastInput != null &&
          DateTime.now().difference(_lastInput!).inMilliseconds >= 500) {
        _translate();
      }
    });
  }

  Future<void> _speak(String text, String lang) async {
    await _flutterTts.setLanguage(lang == 'ru' ? 'ru-RU' : 'en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            _sourceController.text = result.recognizedWords;
            _translate();
          },
          localeId: _sourceLang == 'auto' ? 'ru_RU' : '${_sourceLang}_${_sourceLang.toUpperCase()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Переводчик'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: _buildBody(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Переводчик'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen, color: AppColors.primary),
            onPressed: () => context.push('/translate'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Панель выбора языков
        Padding(
          padding: const EdgeInsets.all(AppPadding.screen),
          child: Row(
            children: [
              _buildLangButton(_sourceLang, true),
              IconButton(
                icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                onPressed: _swapLanguages,
              ),
              _buildLangButton(_targetLang, false),
            ],
          ),
        ),
        // Верхняя часть - ввод текста
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getLangName(_sourceLang),
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: AppColors.textTertiary),
                        onPressed: () {
                          _sourceController.clear();
                          setState(() => _translatedText = '');
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      onChanged: _onTextChanged,
                      style: AppTextStyles.body,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'Введите текст',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? AppColors.primary : AppColors.textSecondary,
                        ),
                        onPressed: _toggleListening,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Нижняя часть - перевод
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLangName(_targetLang),
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isTranslating
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          )
                        : Text(
                            _translatedText.isEmpty ? 'Перевод появится здесь' : _translatedText,
                            style: AppTextStyles.body.copyWith(
                              color: _translatedText.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                  ),
                  if (_translatedText.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: AppColors.primary),
                          onPressed: () => _speak(_translatedText, _targetLang),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: AppColors.primary),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.star_border, color: AppColors.primary),
                          onPressed: () {},
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Кнопка открыть в чате
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/home/chats');
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Открыть в чате'),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLangButton(String langCode, bool isSource) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showLangPicker(isSource),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getFlag(langCode),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _getLangName(langCode),
                  style: AppTextStyles.secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLangPicker(bool isSource) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppPadding.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSource ? 'Язык ввода' : 'Язык перевода',
              style: AppTextStyles.navigation,
            ),
            const SizedBox(height: 16),
            ..._languages.where((l) => isSource || l['code'] != 'auto').map(
                  (lang) => ListTile(
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Text(lang['name']!),
                    trailing: (isSource ? _sourceLang : _targetLang) == lang['code']
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isSource) {
                          _sourceLang = lang['code']!;
                        } else {
                          _targetLang = lang['code']!;
                        }
                      });
                      Navigator.pop(context);
                      if (_sourceController.text.isNotEmpty) {
                        _translate();
                      }
                    },
                  ),
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
