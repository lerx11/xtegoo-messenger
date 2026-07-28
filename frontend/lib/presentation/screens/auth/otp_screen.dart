import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/services/auth_service.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = 60;

  String _phone = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.verifyCode(_phone, code);

      ref.read(authStateProvider.notifier).state = true;
      ref.read(currentUserProvider.notifier).state = user;

      if (mounted) {
        if (user?.username == null || user!.username!.isEmpty) {
          context.go('/auth/username');
        } else {
          context.go('/home/chats');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неверный код')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phone = GoRouterState.of(context).extra as String? ?? '+79991234567';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Введите код',
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Код отправлен на $_phone',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // OTP поля
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.secondarySurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (index == 5 && value.isNotEmpty) {
                          _verifyCode();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Отправить повторно
              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Отправить повторно через $_resendTimer сек',
                        style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: () {
                          setState(() => _resendTimer = 60);
                          _startResendTimer();
                        },
                        child: const Text('Отправить код повторно'),
                      ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Подтвердить'),
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
