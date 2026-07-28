import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isMyProfile = userId == 'me';

    return Scaffold(
      appBar: AppBar(
        title: Text(isMyProfile ? 'Мой профиль' : 'Профиль'),
        leading: isMyProfile
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        actions: isMyProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () => context.push('/profile/edit'),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppPadding.screen),
        children: [
          // Аватар и имя
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.secondarySurface,
                  child: Icon(Icons.person, size: 50, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Иван Иванов',
                  style: AppTextStyles.display,
                ),
                const SizedBox(height: 4),
                const Text(
                  '@ivan_ivanov',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Разработчик мобильных приложений',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Кнопки действий
          if (isMyProfile) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/profile/edit'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Поделиться'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/chat/user_$userId');
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Написать'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondarySurface,
                    minimumSize: const Size(52, 52),
                  ),
                  icon: const Icon(Icons.call, color: AppColors.primary),
                  onPressed: () {
                    context.push('/call/$userId');
                  },
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondarySurface,
                    minimumSize: const Size(52, 52),
                  ),
                  icon: const Icon(Icons.videocam, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          // Бизнес аккаунт
          if (isMyProfile)
            _buildSection(
              title: 'Бизнес',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.store, color: AppColors.primary),
                  title: const Text('Бизнес-аккаунт'),
                  subtitle: const Text('Создайте профиль для бизнеса'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/business/me'),
                ),
              ],
            ),
          // Статистика
          _buildSection(
            title: 'Статистика',
            children: [
              _buildStatRow('Чатов', '24'),
              _buildStatRow('Звонков', '156'),
              _buildStatRow('Переводов', '342'),
            ],
          ),
          // eSIM
          _buildSection(
            title: 'Услуги',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.sim_card, color: AppColors.primary),
                title: const Text('Мои eSIM'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/esim'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            children: [
              ...children.asMap().entries.map(
                (entry) {
                  final isLast = entry.key == children.length - 1;
                  return Column(
                    children: [
                      entry.value,
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.navigation.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
