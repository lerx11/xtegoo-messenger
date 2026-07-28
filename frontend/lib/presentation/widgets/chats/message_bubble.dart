import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/core.dart';
import '../../../data/models/chat.dart';
import '../../screens/chats/chat_screen.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final TranslationState? translation;
  final VoidCallback onLongPress;
  final VoidCallback onTranslate;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.translation,
    required this.onLongPress,
    required this.onTranslate,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speak(String text, String lang) async {
    await _flutterTts.setLanguage(lang);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Пузырь сообщения
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isMe ? AppColors.primary : AppColors.chatBubble,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.translation?.isTranslated == true &&
                        widget.translation!.showOriginal) ...[
                      Text(
                        widget.message.content ?? '',
                        style: AppTextStyles.body.copyWith(
                          color: widget.isMe ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ] else if (widget.translation?.isTranslated != true) ...[
                      Text(
                        widget.message.content ?? '',
                        style: AppTextStyles.body.copyWith(
                          color: widget.isMe ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      FormatUtils.formatTime(widget.message.createdAt),
                      style: AppTextStyles.small.copyWith(
                        color: widget.isMe
                            ? Colors.white.withOpacity(0.7)
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Плашка перевода
              if (widget.translation?.isLoading == true)
                _buildTranslationLoading(),
              if (widget.translation?.isTranslated == true)
                _buildTranslationBubble(),
              if (widget.translation?.hasError == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ошибка перевода',
                    style: AppTextStyles.small.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationLoading() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.translationBubble,
          borderRadius: BorderRadius.circular(AppRadius.translation),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Перевод...',
              style: AppTextStyles.small.copyWith(color: AppColors.translationText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationBubble() {
    final t = widget.translation!;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.translationBubble,
          borderRadius: BorderRadius.circular(AppRadius.translation),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    t.translatedText ?? '',
                    style: AppTextStyles.translation.copyWith(
                      color: AppColors.translationText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _getLangName(t.sourceLang ?? 'en'),
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: widget.onTranslate,
                  child: Text(
                    t.showOriginal ? 'Оригинал' : 'Перевод',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 18, color: AppColors.primary),
                  onPressed: () => _speak(t.translatedText!, 'ru-RU'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLangName(String code) {
    const langs = {
      'en': 'Английский',
      'ru': 'Русский',
      'zh': 'Китайский',
      'es': 'Испанский',
      'fr': 'Французский',
      'de': 'Немецкий',
      'ja': 'Японский',
    };
    return langs[code] ?? code;
  }
}
