import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _darkTheme = false;
  String _appLang = 'Русский';
  String _translateLang = 'Русский';
  String _privacy = 'Все';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppPadding.screen),
        children: [
          // Профиль
          GestureDetector(
            onTap: () => context.push('/profile/me'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 28, color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Иван Иванов', style: AppTextStyles.navigation),
                        SizedBox(height: 2),
                        Text('@ivan_ivanov', style: AppTextStyles.small),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Уведомления
          _buildSectionTitle('Уведомления'),
          _buildSection(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Уведомления'),
                subtitle: const Text('Включить все уведомления'),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Звук'),
                subtitle: const Text('Звук уведомлений'),
                value: _sound,
                onChanged: (v) => setState(() => _sound = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Вибрация'),
                subtitle: const Text('Вибрация при уведомлении'),
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
              ),
            ],
          ),
          // Конфиденциальность
          _buildSectionTitle('Конфиденциальность'),
          _buildSection(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Кто видит профиль'),
                subtitle: Text(_privacy),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Кто видит сторис'),
                subtitle: const Text('Все'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
          // Язык
          _buildSectionTitle('Язык'),
          _buildSection(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Язык приложения'),
                subtitle: Text(_appLang),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Язык перевода'),
                subtitle: Text(_translateLang),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
          // Внешний вид
          _buildSectionTitle('Внешний вид'),
          _buildSection(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Тёмная тема'),
                subtitle: const Text('Включить тёмную тему'),
                value: _darkTheme,
                onChanged: (v) => setState(() => _darkTheme = v),
              ),
            ],
          ),
          // О приложении
          _buildSectionTitle('О приложении'),
          _buildSection(
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Версия'),
                trailing: Text('1.0.0'),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Политика конфиденциальности'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Пользовательское соглашение'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Выйти
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _showLogoutDialog(),
              child: const Text('Выйти', style: TextStyle(color: AppColors.error, fontSize: 17)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти?'),
        content: const Text('Вы действительно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/auth/phone');
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
