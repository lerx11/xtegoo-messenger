import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/services/chat_service.dart';
import '../../widgets/chats/story_ring_widget.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: AppPadding.screen),
          child: GestureDetector(
            onTap: () => context.push('/new-message'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.chipSurface,
                borderRadius: BorderRadius.circular(AppRadius.appBarChip),
              ),
              child: const Icon(
                Icons.edit_square,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Text('Чаты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: AppColors.primary),
            onPressed: () {
              context.push('/search');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isScrolled ? 0 : 60,
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: _isScrolled
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Поиск',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
          ),
          // Сторис
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isScrolled ? 100 : 40,
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: _buildStories(),
          ),
          const SizedBox(height: 8),
          // Список чатов
          Expanded(
            child: chatsAsync.when(
              data: (chats) => ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
                itemCount: chats.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.secondarySurface,
                      child: chat.displayAvatar != null
                          ? ClipOval(
                              child: Image.network(
                                chat.displayAvatar!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 28, color: AppColors.textTertiary),
                              ),
                            )
                          : const Icon(Icons.person, size: 28, color: AppColors.textTertiary),
                    ),
                    title: Text(
                      chat.displayName,
                      style: AppTextStyles.navigation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      chat.lastMessage?.content ?? 'Нет сообщений',
                      style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (chat.lastMessage != null)
                          Text(
                            FormatUtils.formatTime(chat.lastMessage!.createdAt),
                            style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.push('/chat/${chat.id}');
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Ошибка: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    final stories = [
      {'name': 'Моя история', 'isMine': true},
      {'name': 'Анна', 'isMine': false},
      {'name': 'Максим', 'isMine': false},
      {'name': 'Елена', 'isMine': false},
      {'name': 'Дмитрий', 'isMine': false},
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        final story = stories[index];
        return StoryRingWidget(
          name: story['name'] as String,
          isMine: story['isMine'] as bool,
          isExpanded: _isScrolled,
          onTap: () {
            if (story['isMine'] == true) {
              context.push('/story/create');
            } else {
              context.push('/story/user_$index');
            }
          },
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
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
              leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
              title: const Text('Чаты'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: AppColors.primary),
              title: const Text('Каналы'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.topic_outlined, color: AppColors.primary),
              title: const Text('Темы'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
