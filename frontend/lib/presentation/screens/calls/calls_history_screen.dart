import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class CallsHistoryScreen extends ConsumerWidget {
  const CallsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Звонки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Сегодня',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          _buildCallTile(
            context,
            name: 'Анна Иванова',
            avatar: null,
            time: '14:32',
            type: 'incoming',
            callType: 'audio',
            duration: '5:23',
          ),
          _buildCallTile(
            context,
            name: 'Максим Петров',
            avatar: null,
            time: '12:15',
            type: 'outgoing',
            callType: 'video',
            duration: '12:45',
          ),
          _buildCallTile(
            context,
            name: 'Елена Сидорова',
            avatar: null,
            time: '10:08',
            type: 'missed',
            callType: 'audio',
            duration: '',
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Вчера',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          _buildCallTile(
            context,
            name: 'Дмитрий Кузнецов',
            avatar: null,
            time: '18:45',
            type: 'outgoing',
            callType: 'audio',
            duration: '3:12',
          ),
          _buildCallTile(
            context,
            name: 'Ольга Михайлова',
            avatar: null,
            time: '11:20',
            type: 'incoming',
            callType: 'video',
            duration: '28:15',
          ),
        ],
      ),
    );
  }

  Widget _buildCallTile(
    BuildContext context, {
    required String name,
    required String? avatar,
    required String time,
    required String type,
    required String callType,
    required String duration,
  }) {
    Color iconColor;
    IconData icon;

    switch (type) {
      case 'incoming':
        iconColor = AppColors.callIncoming;
        icon = Icons.call_received;
        break;
      case 'outgoing':
        iconColor = AppColors.callOutgoing;
        icon = Icons.call_made;
        break;
      case 'missed':
        iconColor = AppColors.callMissed;
        icon = Icons.call_missed;
        break;
      default:
        iconColor = AppColors.textSecondary;
        icon = Icons.call;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.secondarySurface,
        child: const Icon(Icons.person, size: 24, color: AppColors.textTertiary),
      ),
      title: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            name,
            style: AppTextStyles.body.copyWith(
              color: type == 'missed' ? AppColors.callMissed : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Icon(
            callType == 'video' ? Icons.videocam : Icons.call,
            size: 14,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            duration.isNotEmpty ? duration : 'Пропущен',
            style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              callType == 'video' ? Icons.videocam : Icons.call,
              color: AppColors.primary,
            ),
            onPressed: () {
              context.push('/call/user_1');
            },
          ),
        ],
      ),
    );
  }
}
