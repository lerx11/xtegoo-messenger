import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/core.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.now(): [
      {'title': 'Встреча с клиентом', 'time': '14:00', 'color': AppColors.primary},
      {'title': 'Звонок в Zoom', 'time': '16:30', 'color': Colors.blue},
    ],
    DateTime.now().add(const Duration(days: 2)): [
      {'title': 'Дедлайн проекта', 'time': '18:00', 'color': AppColors.error},
    ],
  };

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
            onPressed: () {
              context.push('/calendar/event/new');
            },
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
        return GestureDetector(
          onTap: () => context.push('/calendar/event/$index'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border(left: BorderSide(color: event['color'], width: 4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title'], style: AppTextStyles.navigation),
                      const SizedBox(height: 4),
                      Text(event['time'], style: AppTextStyles.secondary),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        );
      },
    );
  }
}
