import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/core.dart';

// Категории услуг
const List<String> serviceCategories = [
  'Визажист', 'Фотограф', 'Гид', 'Массажист', 'Парикмахер',
  'Тренер', 'Психолог', 'Репетитор', 'Ветеринар', 'Клининг', 'Другое',
];

// Категории товаров
const List<String> productCategories = [
  'Одежда', 'Электроника', 'Косметика', 'Handmade', 'Книги', 'Другое',
];

class BusinessProfileScreen extends StatefulWidget {
  final String businessId;

  const BusinessProfileScreen({super.key, required this.businessId});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  int _selectedTab = 0;
  final bool _isOwner = true; // В реальности — проверка по текущему юзеру

  // Моковые услуги
  final List<Map<String, dynamic>> _services = [
    {'id': 's1', 'name': 'Массаж спины', 'price': 3500, 'duration': 60, 'category': 'Массажист', 'description': 'Расслабляющий массаж'},
    {'id': 's2', 'name': 'Массаж шеи', 'price': 2000, 'duration': 30, 'category': 'Массажист', 'description': 'Антистресс массаж'},
  ];

  // Моковые товары
  final List<Map<String, dynamic>> _products = [
    {'id': 'p1', 'name': 'Массажное масло', 'price': 990, 'category': 'Косметика', 'images': []},
  ];

  // Моковые записи клиентов
  final List<Map<String, dynamic>> _bookings = [
    {'id': 'b1', 'client': 'Иван', 'service': 'Массаж спины', 'date': DateTime.now().add(const Duration(days: 1)), 'time': '14:00', 'status': 'pending'},
    {'id': 'b2', 'client': 'Мария', 'service': 'Массаж шеи', 'date': DateTime.now().add(const Duration(days: 2)), 'time': '11:00', 'status': 'confirmed'},
  ];

  // Доступные слоты (дни недели и время)
  final Set<int> _availableWeekdays = {1, 2, 3, 4, 5}; // Пн-Пт
  final List<String> _availableSlots = ['10:00', '11:00', '12:00', '14:00', '15:00', '16:00'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Шапка профиля
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: _isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => context.push('/profile/edit'),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.screen),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.store, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Студия массажа "Релакс"',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Профессиональный массаж',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            // Заглушка рейтинга
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                              ),
                              child: const Text(
                                'Рейтинг скоро',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Кнопка записаться (для не-владельца)
                if (!_isOwner)
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.screen),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/business/${widget.businessId}/services'),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Записаться'),
                      ),
                    ),
                  ),

                // Кнопка добавить (для владельца)
                if (_isOwner) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCreateServiceSheet(context),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Услуга'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCreateProductSheet(context),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Товар'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Табы
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
                  child: Row(
                    children: [
                      _buildTab('Услуги', 0),
                      _buildTab('Товары', 1),
                      _buildTab('Календарь', 2),
                      _buildTab('Записи', 3),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Контент таба
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
                  child: _buildTabContent(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildServicesTab();
      case 1:
        return _buildProductsTab();
      case 2:
        return _buildCalendarTab();
      case 3:
        return _buildBookingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // Таб услуг
  Widget _buildServicesTab() {
    if (_services.isEmpty) {
      return const Center(child: Text('Нет услуг', style: AppTextStyles.body));
    }
    return Column(
      children: _services.map((s) => _buildServiceItem(s)).toList(),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['name'], style: AppTextStyles.navigation),
                const SizedBox(height: 4),
                Text('${service['duration']} мин · ${service['category']}', style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
                if (service['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(service['description'], style: AppTextStyles.small.copyWith(color: AppColors.textTertiary)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${service['price']} ₽', style: AppTextStyles.navigation.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              if (_isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: () => setState(() => _services.remove(service)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                TextButton(
                  onPressed: () => context.push('/booking/${service['id']}'),
                  child: const Text('Записаться'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Таб товаров
  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return const Center(child: Text('Нет товаров', style: AppTextStyles.body));
    }
    return Column(
      children: _products.map((p) => _buildProductItem(p)).toList(),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Icon(Icons.image, size: 28, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], style: AppTextStyles.navigation),
                const SizedBox(height: 4),
                Text(product['category'], style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${product['price']} ₽', style: AppTextStyles.navigation.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              if (_isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: () => setState(() => _products.remove(product)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                TextButton(
                  onPressed: () => context.push('/product/${product['id']}'),
                  child: const Text('Купить'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Таб календаря — управление доступными слотами
  Widget _buildCalendarTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Доступные дни недели', style: AppTextStyles.navigation),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].asMap().entries.map((entry) {
            final dayIndex = entry.key + 1;
            final isSelected = _availableWeekdays.contains(dayIndex);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _availableWeekdays.remove(dayIndex);
                  } else {
                    _availableWeekdays.add(dayIndex);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  entry.value,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Временные слоты', style: AppTextStyles.navigation),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSlots.map((slot) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.translationBubble,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                slot,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Календарь с занятыми/свободными слотами
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          calendarStyle: CalendarStyle(
            todayDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: AppTextStyles.body,
            weekendTextStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            // Занятые дни — красным, свободные — зелёным
            markerDecoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.navigation,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildLegend(AppColors.success, 'Свободно'),
            const SizedBox(width: 16),
            _buildLegend(AppColors.error, 'Занято'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  // Таб записей клиентов
  Widget _buildBookingsTab() {
    if (_bookings.isEmpty) {
      return const Center(child: Text('Нет записей', style: AppTextStyles.body));
    }
    return Column(
      children: _bookings.map((b) => _buildBookingItem(b)).toList(),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    final isPending = booking['status'] == 'pending';
    final dateStr = '${booking['date'].day}.${booking['date'].month}.${booking['date'].year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border(
          left: BorderSide(
            color: isPending ? AppColors.warning : AppColors.success,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Клиент: ${booking['client']}', style: AppTextStyles.navigation),
                const SizedBox(height: 4),
                Text('Услуга: ${booking['service']}', style: AppTextStyles.secondary),
                const SizedBox(height: 4),
                Text('$dateStr в ${booking['time']}', style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isPending && _isOwner) ...[
            IconButton(
              icon: const Icon(Icons.check_circle, color: AppColors.success),
              onPressed: () => setState(() => booking['status'] = 'confirmed'),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: AppColors.error),
              onPressed: () => setState(() => booking['status'] = 'cancelled'),
            ),
          ] else if (!isPending) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: booking['status'] == 'confirmed' ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                booking['status'] == 'confirmed' ? 'Подтверждено' : 'Отменено',
                style: AppTextStyles.small.copyWith(
                  color: booking['status'] == 'confirmed' ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Bottom sheet создания услуги
  void _showCreateServiceSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    String selectedCategory = serviceCategories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: AppPadding.screen,
              right: AppPadding.screen,
              top: AppPadding.screen,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Новая услуга', style: AppTextStyles.navigation),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Название')),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(hintText: 'Описание'), maxLines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(hintText: 'Цена ₽'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: durationController, decoration: const InputDecoration(hintText: 'Минут'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Категория', style: AppTextStyles.secondary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: serviceCategories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          cat,
                          style: AppTextStyles.small.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        setState(() {
                          _services.add({
                            'id': 's${_services.length + 1}',
                            'name': nameController.text,
                            'description': descController.text,
                            'price': int.tryParse(priceController.text) ?? 0,
                            'duration': int.tryParse(durationController.text) ?? 60,
                            'category': selectedCategory,
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Создать'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Bottom sheet создания товара
  void _showCreateProductSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = productCategories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: AppPadding.screen,
              right: AppPadding.screen,
              top: AppPadding.screen,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Новый товар', style: AppTextStyles.navigation),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Название')),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(hintText: 'Описание'), maxLines: 2),
                const SizedBox(height: 12),
                TextField(controller: priceController, decoration: const InputDecoration(hintText: 'Цена ₽'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                const Text('Категория', style: AppTextStyles.secondary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: productCategories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          cat,
                          style: AppTextStyles.small.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Заглушка для фото
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: AppColors.textTertiary),
                        SizedBox(width: 8),
                        Text('Добавить фото', style: AppTextStyles.secondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        setState(() {
                          _products.add({
                            'id': 'p${_products.length + 1}',
                            'name': nameController.text,
                            'description': descController.text,
                            'price': int.tryParse(priceController.text) ?? 0,
                            'category': selectedCategory,
                            'images': [],
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Создать'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
