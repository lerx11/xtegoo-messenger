import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/services/auth_service.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedCountryCode = '+7';

  Future<void> _sendCode() async {
    final phone = '$_selectedCountryCode${_phoneController.text}';
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendCode(phone);
      if (mounted) {
        context.push('/auth/otp', extra: phone);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.chat_bubble, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Введите номер телефона',
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Мы отправим код подтверждения',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Поле ввода телефона
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showCountryPicker(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _selectedCountryCode,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText: '999 123 45 67',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Продолжить'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final countries = [
      {'code': '+7', 'name': 'Россия', 'flag': '🇷🇺'},
      {'code': '+1', 'name': 'США', 'flag': '🇺🇸'},
      {'code': '+86', 'name': 'Китай', 'flag': '🇨🇳'},
      {'code': '+44', 'name': 'Великобритания', 'flag': '🇬🇧'},
      {'code': '+49', 'name': 'Германия', 'flag': '🇩🇪'},
    ];

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
            const Text('Выберите страну', style: AppTextStyles.navigation),
            const SizedBox(height: 16),
            ...countries.map(
              (country) => ListTile(
                leading: Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(country['name']!),
                trailing: Text(country['code']!, style: const TextStyle(color: AppColors.textSecondary)),
                onTap: () {
                  setState(() => _selectedCountryCode = country['code']!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
