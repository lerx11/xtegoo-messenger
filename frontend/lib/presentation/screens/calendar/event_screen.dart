import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class EventScreen extends StatefulWidget {
  final String? eventId;

  const EventScreen({super.key, this.eventId});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _titleController = TextEditingController(text: 'Встреча с клиентом');
  final _descController = TextEditingController(text: 'Обсудить детали проекта');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  String _selectedColor = 'primary';

  final List<Color> _colors = const [
    AppColors.primary,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

  bool get _isNew => widget.eventId == null || widget.eventId == 'new';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Новое событие' : 'Событие'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => context.pop(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: AppTextStyles.display,
              decoration: const InputDecoration(
                hintText: 'Название события',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),
            _buildRow(
              icon: Icons.calendar_today,
              label: 'Дата',
              value: FormatUtils.formatDate(_selectedDate),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const Divider(height: 32),
            _buildRow(
              icon: Icons.access_time,
              label: 'Время',
              value: _selectedTime.format(context),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
            ),
            const Divider(height: 32),
            _buildColorPicker(),
            const Divider(height: 32),
            const Text('Описание', style: AppTextStyles.navigation),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Добавьте описание',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(_isNew ? 'Создать' : 'Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(label, style: AppTextStyles.body),
          const Spacer(),
          Text(value, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: [
        const Icon(Icons.color_lens, color: AppColors.primary),
        const SizedBox(width: 16),
        const Text('Цвет', style: AppTextStyles.body),
        const Spacer(),
        ..._colors.map(
          (color) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
