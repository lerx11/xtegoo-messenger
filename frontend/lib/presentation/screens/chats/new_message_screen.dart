import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

/// Экран «Написать сообщение».
///
/// Открывается по тапу на иконку карандаша в AppBar экрана чатов.
/// Содержит:
/// - Кнопку «Отмена» слева
/// - Заголовок «Написать сообщение»
/// - Строку поиска контактов
/// - Три кнопки синим текстом: «Создать группу», «Создать контакт», «Создать канал»
/// - Список контактов по алфавиту (моковые данные)
class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _searchController = TextEditingController();

  // Моковые контакты (имя, подзаголовок, аватар-инициалы)
  final List<_Contact> _allContacts = [
    _Contact(name: 'Алексей Иванов', subtitle: 'last seen recently', initials: 'АИ'),
    _Contact(name: 'Анна Смирнова', subtitle: 'был(а) сегодня', initials: 'АС'),
    _Contact(name: 'Борис Кузнецов', subtitle: 'last seen recently', initials: 'БК'),
    _Contact(name: 'Виктория Соколова', subtitle: 'был(а) вчера', initials: 'ВС'),
    _Contact(name: 'Григорий Попов', subtitle: 'last seen recently', initials: 'ГП'),
    _Contact(name: 'Дмитрий Левин', subtitle: 'был(а) сегодня', initials: 'ДЛ'),
    _Contact(name: 'Елена Морозова', subtitle: 'last seen recently', initials: 'ЕМ'),
    _Contact(name: 'Жанна Новикова', subtitle: 'был(а) вчера', initials: 'ЖН'),
    _Contact(name: 'Игорь Волков', subtitle: 'last seen recently', initials: 'ИВ'),
    _Contact(name: 'Кристина Зайцева', subtitle: 'был(а) сегодня', initials: 'КЗ'),
    _Contact(name: 'Максим Павлов', subtitle: 'last seen recently', initials: 'МП'),
    _Contact(name: 'Наталья Семёнова', subtitle: 'был(а) вчера', initials: 'НС'),
    _Contact(name: 'Олег Голубев', subtitle: 'last seen recently', initials: 'ОГ'),
    _Contact(name: 'Ольга Васильева', subtitle: 'был(а) сегодня', initials: 'ОВ'),
  ];

  List<_Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(_allContacts);
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Фильтрация контактов по поисковому запросу (без учёта регистра)
  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts
            .where((c) => c.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Отмена',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        title: const Text('Написать сообщение', style: AppTextStyles.screenTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Строка поиска контактов
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.screen,
              vertical: 8,
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Поиск контактов',
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Три кнопки синим текстом
          _buildActionTile(
            icon: Icons.group_add,
            iconBg: const Color(0xFFE7F3FF),
            iconColor: const Color(0xFF007AFF),
            title: 'Создать группу',
            onTap: () => context.push('/create-group'),
          ),
          _buildActionTile(
            icon: Icons.person_add,
            iconBg: const Color(0xFFE7F3FF),
            iconColor: const Color(0xFF007AFF),
            title: 'Создать контакт',
            onTap: () => context.push('/create-contact'),
          ),
          _buildActionTile(
            icon: Icons.campaign_outlined,
            iconBg: const Color(0xFFE7F3FF),
            iconColor: const Color(0xFF007AFF),
            title: 'Создать канал',
            onTap: () => context.push('/create-channel'),
          ),
          const Divider(height: 1, indent: AppPadding.screen),
          // Список контактов по алфавиту
          Expanded(
            child: _filteredContacts.isEmpty
                ? const Center(
                    child: Text(
                      'Контакты не найдены',
                      style: AppTextStyles.secondary,
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 76),
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return _buildContactTile(contact);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Tile с иконкой в синей круглой плашке и синим заголовком
  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppPadding.screen,
        vertical: 4,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }

  // Tile контакта
  Widget _buildContactTile(_Contact contact) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.secondarySurface,
        child: Text(
          contact.initials,
          style: AppTextStyles.navigation.copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(
        contact.name,
        style: AppTextStyles.navigation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        contact.subtitle,
        style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // Заглушка: здесь будет создание чата с выбранным контактом
      },
    );
  }
}

// Простая модель контакта для моковых данных
class _Contact {
  final String name;
  final String subtitle;
  final String initials;

  _Contact({
    required this.name,
    required this.subtitle,
    required this.initials,
  });
}
