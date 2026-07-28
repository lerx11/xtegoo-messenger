import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/core.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;

  const BookingScreen({super.key, required this.serviceId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;

  final List<String> _timeSlots = [
    '10:00', '10:30', '11:00', '11:30',
    '12:00', '13:00', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на услугу'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Услуга
          Container(
            padding: const EdgeInsets.all(AppPadding.screen),
            color: AppColors.secondarySurface,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.build, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Замена экрана iPhone', style: AppTextStyles.navigation),
                      SizedBox(height: 4),
                      Text('60 минут • 4 990 ₽', style: AppTextStyles.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppPadding.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Выберите дату', style: AppTextStyles.navigation),
                  const SizedBox(height: 12),
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedTime = null;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    availableGestures: AvailableGestures.none,
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  ),
                  const SizedBox(height: 24),
                  const Text('Выберите время', style: AppTextStyles.navigation),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedTime = time);
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 40 - 32) / 4,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Text(
                            time,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.secondary.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Кнопка подтверждения
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.screen),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDay != null && _selectedTime != null
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Запись подтверждена!')),
                          );
                          context.pop();
                        }
                      : null,
                  child: const Text('Подтвердить запись'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
