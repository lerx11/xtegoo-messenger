import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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

  // Режим редактирования чатов (выбор + удаление)
  bool _isEditMode = false;
  // Выбранные чаты (по id)
  final Set<String> _selectedChatIds = {};

  // Для выбора фото сторис (камера/галерея)
  final ImagePicker _imagePicker = ImagePicker();

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

  // Вход/выход из режима редактирования
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedChatIds.clear();
      }
    });
  }

  // Переключение выбора чата
  void _toggleChatSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  // Удаление выбранных чатов (заглушка: просто очищаем выбор и выходим)
  void _deleteSelected() {
    // TODO: реализовать реальное удаление через chatService
    setState(() {
      _selectedChatIds.clear();
      _isEditMode = false;
    });
  }

  // BottomSheet выбора источника для сторис: Камера / Галерея
  void _showStorySourceSheet() {
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
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined, color: AppColors.primary),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Выбор изображения через image_picker
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        context.push('/story/create');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось выбрать изображение: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatsProvider);

    return Scaffold(
      appBar: _buildAppBar(),
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
                  final isSelected = _selectedChatIds.contains(chat.id);

                  // В режиме редактирования показываем чекбокс
                  if (_isEditMode) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Чекбокс выбора
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.secondarySurface,
                            child: chat.displayAvatar != null
                                ? ClipOval(
                                    child: Image.network(
                                      chat.displayAvatar!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 28,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.person, size: 28, color: AppColors.textTertiary),
                          ),
                        ],
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
                      onTap: () => _toggleChatSelection(chat.id),
                    );
                  }

                  // Обычный режим (как было)
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

  // AppBar:
  // - Слева: «Изм.» / «Готово» в округлой плашке (фон #F2F3F5, радиус 18)
  // - Центр: «Чаты» (17px semibold) или количество выбранных в режиме редактирования
  // - Справа: ОДНА плашка с двумя иконками (edit_outlined → /new-message, add → BottomSheet)
  AppBar _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: AppPadding.screen),
        child: GestureDetector(
          onTap: _toggleEditMode,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.chipSurface,
              borderRadius: BorderRadius.circular(AppRadius.appBarChip),
            ),
            alignment: Alignment.center,
            child: Text(
              _isEditMode ? 'Готово' : 'Изм.',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        _isEditMode && _selectedChatIds.isNotEmpty
            ? '${_selectedChatIds.length}'
            : 'Чаты',
        style: AppTextStyles.navigation,
      ),
      centerTitle: true,
      actions: [
        // В режиме редактирования с выбранными чатами — кнопка удаления
        if (_isEditMode && _selectedChatIds.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteSelected,
          )
        else
          // ОДНА плашка с двумя иконками
          Padding(
            padding: const EdgeInsets.only(right: AppPadding.screen),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.chipSurface,
                borderRadius: BorderRadius.circular(AppRadius.appBarChip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Карандаш → /new-message
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    onPressed: () => context.push('/new-message'),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                    splashRadius: 18,
                  ),
                  // Вертикальный разделитель
                  Container(
                    width: 1,
                    height: 20,
                    color: AppColors.border,
                  ),
                  // Плюс → BottomSheet Камера/Галерея
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary, size: 22),
                    onPressed: _showStorySourceSheet,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
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
}
