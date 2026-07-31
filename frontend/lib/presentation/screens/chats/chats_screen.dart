import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});
  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  bool _isEditMode = false;
  bool _isExpanded = false;
  final Set<String> _selectedChatIds = {};

  final List<Map<String, dynamic>> _stories = [
    {'name': 'Моя история', 'isMine': true},
    {'name': 'Анна', 'isMine': false},
    {'name': 'Максим', 'isMine': false},
    {'name': 'Елена', 'isMine': false},
    {'name': 'Дмитрий', 'isMine': false},
  ];

  final List<Map<String, dynamic>> _chats = [
    {'id': '1', 'name': 'Анна', 'lastMessage': 'Привет!', 'time': '12:30', 'unread': 2},
    {'id': '2', 'name': 'Максим', 'lastMessage': 'Договорились', 'time': '11:15', 'unread': 0},
    {'id': '3', 'name': 'Команда XTegoo', 'lastMessage': 'Олег: файл готов', 'time': '10:00', 'unread': 5},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final expand = _scrollController.hasClients && _scrollController.offset < 50;
      if (expand != _isExpanded) setState(() => _isExpanded = expand);
    });
  }
  @override
  void dispose() { _scrollController.dispose(); _searchController.dispose(); super.dispose(); }

  void _toggleEditMode() => setState(() { _isEditMode = !_isEditMode; _selectedChatIds.clear(); });
  void _toggleChatSelection(String id) => setState(() {
    if (_selectedChatIds.contains(id)) _selectedChatIds.remove(id); else _selectedChatIds.add(id);
  });
  void _deleteSelected() => setState(() {
    _chats.removeWhere((c) => _selectedChatIds.contains(c['id'])); _selectedChatIds.clear(); _isEditMode = false;
  });
  void _showStorySourceSheet() {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Камера'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Галерея'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
    ])));
  }
  Future<void> _pickImage(ImageSource source) async {
    try { final image = await _picker.pickImage(source: source); if (image != null && mounted) context.push('/story/create'); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка'))); }
  }

  // ─── APPBAR ────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background, elevation: 0, titleSpacing: 0,
      title: Row(children: [
        const SizedBox(width: 4),
        _buildChip(_isEditMode ? 'Готово' : 'Изм.', _toggleEditMode),
        const Spacer(),
        Opacity(opacity: _isExpanded ? 0.0 : 1.0, child: _buildCollapsedStories()),
        const SizedBox(width: 8),
        Text(_isEditMode && _selectedChatIds.isNotEmpty ? '${_selectedChatIds.length}' : 'Чаты', style: AppTextStyles.navigation),
        const Spacer(),
        _buildRightChip(),
        const SizedBox(width: 4),
      ]),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(
      height: 36, padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppColors.chipSurface, borderRadius: BorderRadius.circular(18)),
      alignment: Alignment.center, child: Text(label, style: AppTextStyles.secondary.copyWith(color: AppColors.primary)),
    ));
  }

  Widget _buildRightChip() {
    if (_isEditMode && _selectedChatIds.isNotEmpty) return IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: _deleteSelected);
    return Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: AppColors.chipSurface, borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.add, color: AppColors.primary, size: 22), onPressed: _showStorySourceSheet, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36), splashRadius: 18),
        Container(width: 1, height: 20, color: AppColors.border),
        IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20), onPressed: () => context.push('/new-message'), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36), splashRadius: 18),
      ]));
  }

  Widget _buildCollapsedStories() {
    return SizedBox(width: 60, height: 32, child: Stack(clipBehavior: Clip.none, children: List.generate(
      _stories.length > 3 ? 3 : _stories.length, (i) => Positioned(left: i * 14.0, child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2), color: AppColors.secondarySurface)),
      ))),
    ));
  }

  // ─── РАЗВЁРНУТЫЕ СТОРИС ──────────────
  Widget _buildExpandedStories() {
    return Container(
      height: _isExpanded ? 110 : 0,
      child: Opacity(opacity: _isExpanded ? 1.0 : 0.0,
        child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: _stories.length,
          itemBuilder: (context, index) {
            final s = _stories[index];
            final circle = Container(width: 68, height: 68, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2), color: AppColors.secondarySurface),
              child: s['isMine'] == true ? const Icon(Icons.person, size: 34, color: AppColors.textTertiary) : null);
            return Padding(padding: const EdgeInsets.only(right: 16), child: Column(children: [
              s['isMine'] == true
                  ? GestureDetector(onTap: _showStorySourceSheet, child: Stack(clipBehavior: Clip.none, children: [
                      circle, Positioned(right: 2, bottom: 2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.add, size: 14, color: Colors.white))),
                    ]))
                  : circle,
              const SizedBox(height: 4), Text(s['name'] as String, style: AppTextStyles.small),
            ]));
          },
        ),
      ),
    );
  }

  // ─── ПОИСК ─────────────────────────────
  Widget _buildSearch() {
    return Container(height: _isExpanded ? 56 : 0,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), child: TextField(
        controller: _searchController,
        decoration: InputDecoration(hintText: 'Поиск', prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          filled: true, fillColor: AppColors.secondarySurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      )));
  }

  // ─── ЧАТЫ ──────────────────────────────
  Widget _buildChatList() {
    if (_chats.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Нет чатов', style: AppTextStyles.body),
    ]));
    return ListView.separated(controller: _scrollController, physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.zero, itemCount: _chats.length, separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return ListTile(
          leading: CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text((chat['name'] as String)[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          title: Text(chat['name'] as String, style: AppTextStyles.navigation),
          subtitle: Text(chat['lastMessage'] as String, style: AppTextStyles.secondary),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(chat['time'] as String, style: AppTextStyles.small),
            if ((chat['unread'] as int) > 0) ...[ const SizedBox(height: 4), Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Text('${chat['unread']}', style: const TextStyle(color: Colors.white, fontSize: 11)))],
          ]),
          onTap: _isEditMode ? () => _toggleChatSelection(chat['id'] as String) : () => context.push('/chat/${chat['id']}'),
          selected: _selectedChatIds.contains(chat['id']),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(children: [_buildExpandedStories(), _buildSearch(), Expanded(child: _buildChatList())]),
    );
  }
}
