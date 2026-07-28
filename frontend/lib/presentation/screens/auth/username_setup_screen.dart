import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/auth_service.dart';

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  final _controller = TextEditingController();
  bool _isChecking = false;
  bool _isAvailable = false;
  bool _isSaving = false;

  Future<void> _checkUsername(String username) async {
    if (username.length < 3) {
      setState(() {
        _isAvailable = false;
        _isChecking = false;
      });
      return;
    }

    setState(() => _isChecking = true);

    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.checkUsername(username);
      setState(() {
        _isAvailable = result;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _saveUsername() async {
    if (!_isAvailable) return;

    setState(() => _isSaving = true);

    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.updateUsername(_controller.text);
      ref.read(currentUserProvider.notifier).state = user;

      if (mounted) {
        context.go('/home/chats');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите ник'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Выберите уникальный ник',
                style: AppTextStyles.display,
              ),
              const SizedBox(height: 8),
              Text(
                'Ваши друзья смогут найти вас по нику',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Поле ввода
              TextField(
                controller: _controller,
                onChanged: (value) {
                  _checkUsername(value.replaceAll('@', ''));
                },
                decoration: InputDecoration(
                  hintText: 'username',
                  prefixText: '@ ',
                  suffixIcon: _controller.text.isNotEmpty
                      ? _isChecking
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _isAvailable
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : const Icon(Icons.error, color: AppColors.error)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              if (_controller.text.isNotEmpty && !_isChecking)
                Text(
                  _isAvailable
                      ? 'Ник свободен!'
                      : 'Этот ник уже занят',
                  style: AppTextStyles.secondary.copyWith(
                    color: _isAvailable ? AppColors.success : AppColors.error,
                  ),
                ),
              const SizedBox(height: 16),
              // Подсказки
              Text(
                'Ник должен:\n• Начинаться с буквы\n• Содержать 3-32 символа\n• Буквы, цифры и подчёркивание',
                style: AppTextStyles.secondary.copyWith(color: AppColors.textTertiary),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAvailable && !_isSaving ? _saveUsername : null,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Готово'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
