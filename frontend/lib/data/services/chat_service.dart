import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/chat.dart';
import '../models/user.dart';

class ChatService {
  final ApiService _api;

  ChatService(this._api);

  Future<List<Chat>> getChats() async {
    final response = await _api.get('/chats/list');
    return (response.data as List).map((e) => Chat.fromJson(e)).toList();
  }

  Future<Chat> createChat(String targetUserId) async {
    final response = await _api.post('/chats/create', data: {
      'targetUserId': targetUserId,
    });
    return Chat.fromJson(response.data);
  }

  Future<List<Message>> getMessages(String chatId, {String? cursor, int limit = 50}) async {
    final response = await _api.get(
      '/chats/$chatId/messages',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit.toString(),
      },
    );
    return (response.data as List).map((e) => Message.fromJson(e)).toList();
  }

  Future<Message> sendMessage(
    String chatId,
    String content, {
    String type = 'text',
    String? fileUrl,
    String? replyToId,
  }) async {
    final response = await _api.post('/chats/$chatId/messages', data: {
      'content': content,
      'type': type,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (replyToId != null) 'replyToId': replyToId,
    });
    return Message.fromJson(response.data);
  }

  Future<void> markAsRead(String chatId) async {
    await _api.post('/chats/$chatId/read');
  }

  Future<List<User>> searchUsers(String query) async {
    final response = await _api.get('/users/search', queryParameters: {'q': query});
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ApiService();
  return ChatService(apiService);
});

final chatsProvider = FutureProvider<List<Chat>>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChats();
});
