import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/models/chat.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/translate_service.dart';
import '../../widgets/chats/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool isGroup;

  const ChatScreen({super.key, required this.chatId, this.isGroup = false});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  final Map<String, TranslationState> _translations = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getMessages(widget.chatId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final chatService = ref.read(chatServiceProvider);
      final message = await chatService.sendMessage(widget.chatId, text);
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки: $e')),
      );
    }
  }

  Future<void> _translateMessage(Message message) async {
    if (_translations[message.id]?.isTranslated == true) {
      setState(() {
        _translations[message.id]!.showOriginal = !_translations[message.id]!.showOriginal;
      });
      return;
    }

    setState(() {
      _translations[message.id] = TranslationState(isLoading: true);
    });

    try {
      final translateService = ref.read(translateServiceProvider);
      final result = await translateService.translate(
        message.content ?? '',
        'ru',
      );

      setState(() {
        _translations[message.id] = TranslationState(
          isLoading: false,
          isTranslated: true,
          translatedText: result.translatedText,
          sourceLang: result.sourceLang,
          showOriginal: true,
        );
      });
    } catch (e) {
      setState(() {
        _translations[message.id] = TranslationState(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
        );
      });
    }
  }

  void _showMessageMenu(Message message) {
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
            ListTile(
              leading: const Icon(Icons.translate, color: AppColors.primary),
              title: const Text('Перевести'),
              onTap: () {
                Navigator.pop(context);
                _translateMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.textSecondary),
              title: const Text('Копировать'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.textSecondary),
              title: const Text('Ответить'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward, color: AppColors.textSecondary),
              title: const Text('Переслать'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Удалить', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondarySurface,
              child: Icon(Icons.person, size: 20, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Анна Иванова',
                  style: AppTextStyles.navigation,
                ),
                Text(
                  'в сети',
                  style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Сообщения
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Начните общение',
                          style: AppTextStyles.body,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.screen,
                          vertical: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[_messages.length - 1 - index];
                          final isMe = message.senderId == 'me';
                          final translation = _translations[message.id];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MessageBubble(
                              message: message,
                              isMe: isMe,
                              translation: translation,
                              onLongPress: () => _showMessageMenu(message),
                              onTranslate: () => _translateMessage(message),
                            ),
                          );
                        },
                      ),
          ),
          // Поле ввода
          Container(
            padding: const EdgeInsets.all(AppPadding.screen),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Сообщение',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic_none, color: AppColors.textSecondary),
                          onPressed: () {},
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TranslationState {
  final bool isLoading;
  final bool isTranslated;
  final bool hasError;
  final String? translatedText;
  final String? sourceLang;
  final String? errorMessage;
  bool showOriginal;

  TranslationState({
    this.isLoading = false,
    this.isTranslated = false,
    this.hasError = false,
    this.translatedText,
    this.sourceLang,
    this.errorMessage,
    this.showOriginal = true,
  });
}
