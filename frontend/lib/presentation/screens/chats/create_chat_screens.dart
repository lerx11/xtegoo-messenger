import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Заглушка экрана «Создание группы».
class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderScreen(
      title: 'Создание группы',
      message: 'Создание группы — скоро',
    );
  }
}

/// Заглушка экрана «Новый контакт».
class CreateContactScreen extends StatelessWidget {
  const CreateContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderScreen(
      title: 'Новый контакт',
      message: 'Новый контакт — скоро',
    );
  }
}

/// Заглушка экрана «Создание канала».
class CreateChannelScreen extends StatelessWidget {
  const CreateChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderScreen(
      title: 'Создание канала',
      message: 'Создание канала — скоро',
    );
  }
}

/// Базовый экран-заглушка: AppBar с названием и кнопкой «Назад»,
/// по центру — текст.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const _PlaceholderScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: AppTextStyles.screenTitle),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.screen),
          child: Text(
            message,
            style: AppTextStyles.secondary.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
