import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/core.dart';

// Тип события календаря
enum CalendarEventType {
  personal,    // Личное событие — Primary
  myBooking,   // Моя запись к бизнесу — синий
  clientBooking, // Запись клиента ко мне — зелёный
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final bool _isBusiness = true; // В реальности — из профиля пользователя

  // Все события (личные + бизнес-записи)
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _selectedDay = DateTime.now();
  }

  // Загрузка событий (моковые данные)
  void _loadEvents() {
    final today = DateTime.now();

    // Личное событие
    _addEvent(today, {
      'type': CalendarEventType.personal,
      'title': 'Встреча с командой',
      'description': 'Обсуждение нового дизайна',
      'time': '14:00',
      'color': AppColors.primary,
    });

    // Моя запись к бизнесу (клиент видит)
    _addEvent(today.add(const Duration(days: 1)), {
      'type': CalendarEventType.myBooking,
      'title': 'Вы записаны на Массаж к Елене',
      'description': 'Массаж спины, 60 мин',
      'time': '15:00',
      'color': Colors.blue,
    });

    // Запись клиента ко мне (бизнес видит)
    if (_isBusiness) {
      _addEvent(today.add(const Duration(days: 1)), {
        'type': CalendarEventType.clientBooking,
        'title': 'Клиент Иван записан на Массаж',
        'description': 'Массаж шеи, 30 мин',
        'time': '11:00',
        'color': AppColors.success,
      });
      _addEvent(today.add(const Duration(days: 2)), {
        'type': CalendarEventType.clientBooking,
        'title': 'Клиент Мария записана на Массаж',
        'description': 'Массаж спины, 60 мин',
        'time': '14:00',
        'color': AppColors.success,
      });
    }

    // Ещё личные
    _addEvent(today.add(const Duration(days: 3)), {
      'type': CalendarEventType.personal,
      'title': 'Дедлайн проекта',
      'description': '',
      'time': '18:00',
      'color': AppColors.error,
    });
  }

  void _addEvent(DateTime day, Map<String, dynamic> event) {
    final key = DateTime(day.year, day.month, day.day);
    _events.putIfAbsent(key, () => []);
    _events[key]!.add(event);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showCreateEventSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Календарь
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 7,
              defaultTextStyle: AppTextStyles.body,
              weekendTextStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              titleTextStyle: AppTextStyles.navigation,
            ),
          ),
          const Divider(height: 1),

          // Легенда цветов
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen, vertical: 8),
            child: Row(
              children: [
                _buildLegend(AppColors.primary, 'Личные'),
                const SizedBox(width: 16),
                _buildLegend(Colors.blue, 'Мои записи'),
                if (_isBusiness) ...[
                  const SizedBox(width: 16),
                  _buildLegend(AppColors.success, 'Записи клиентов'),
                ],
              ],
            ),
          ),

          // События выбранного дня
          Expanded(
            child: _selectedDay != null
                ? _buildEventsList(_getEventsForDay(_selectedDay!))
                : const Center(
                    child: Text('Выберите дату', style: AppTextStyles.body),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEventsList(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text('Нет событий', style: AppTextStyles.body),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppPadding.screen),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event, index);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, int index) {
    final type = event['type'] as CalendarEventType;
    final typeLabel = type == CalendarEventType.personal
        ? 'Личное'
        : type == CalendarEventType.myBooking
            ? 'Моя запись'
            : 'Запись клиента';

    return GestureDetector(
      onTap: () => _showEventDetails(event, index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border(
            left: BorderSide(color: event['color'] as Color, width: 4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Бейдж типа
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (event['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      typeLabel,
                      style: AppTextStyles.small.copyWith(
                        color: event['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(event['title'], style: AppTextStyles.navigation),
                  if (event['description'] != null && (event['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(event['description'], style: AppTextStyles.secondary),
                  ],
                  const SizedBox(height: 4),
                  Text(event['time'], style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  // Просмотр деталей события
  void _showEventDetails(Map<String, dynamic> event, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppPadding.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(event['title'], style: AppTextStyles.screenTitle),
            const SizedBox(height: 8),
            if (event['description'] != null && (event['description'] as String).isNotEmpty)
              Text(event['description'], style: AppTextStyles.body),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(event['time'], style: AppTextStyles.secondary),
              ],
            ),
            const SizedBox(height: 20),
            if (event['type'] == CalendarEventType.personal)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/calendar/event/$index');
                  },
                  child: const Text('Редактировать'),
                ),
              ),
            if (event['type'] == CalendarEventType.myBooking)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Отменить запись'),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Создание нового события
  void _showCreateEventSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final timeController = TextEditingController();
    Color selectedColor = AppColors.primary;
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    final colorOptions = [
      {'color': AppColors.primary, 'name': 'Primary'},
      {'color': Colors.blue, 'name': 'Blue'},
      {'color': AppColors.success, 'name': 'Green'},
      {'color': AppColors.error, 'name': 'Red'},
      {'color': AppColors.warning, 'name': 'Orange'},
      {'color': Colors.purple, 'name': 'Purple'},
    ];

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
                const Text('Новое событие', style: AppTextStyles.navigation),
                const SizedBox(height: 16),
                TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Заголовок')),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(hintText: 'Описание'), maxLines: 2),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(hintText: 'Время (ЧЧ:ММ)'),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 12),
                const Text('Цвет', style: AppTextStyles.secondary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colorOptions.map((opt) {
                    final color = opt['color'] as Color;
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.textPrimary : Colors.transparent,
                            width: 3,
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
                      if (titleController.text.isNotEmpty) {
                        setState(() {
                          _addEvent(selectedDate, {
                            'type': CalendarEventType.personal,
                            'title': titleController.text,
                            'description': descController.text,
                            'time': timeController.text.isEmpty ? 'Весь день' : timeController.text,
                            'color': selectedColor,
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
