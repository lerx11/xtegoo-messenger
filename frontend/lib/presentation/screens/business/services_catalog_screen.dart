import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class ServicesCatalogScreen extends StatelessWidget {
  final String businessId;

  const ServicesCatalogScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Услуги'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppPadding.screen),
        children: [
          // Категории
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categories = ['Все', 'Ремонт', 'Диагностика', 'Настройка', 'Аксессуары'];
                final isSelected = index == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text(
                    categories[index],
                    style: AppTextStyles.secondary.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Поиск
          const TextField(
            decoration: InputDecoration(
              hintText: 'Поиск услуг',
              prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 16),
          // Список услуг
          _buildServiceCard(
            context,
            name: 'Диагностика устройства',
            description: 'Полная диагностика с отчётом',
            price: 'Бесплатно',
            duration: '30 минут',
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            context,
            name: 'Замена экрана iPhone',
            description: 'Оригинальный экран, гарантия 6 месяцев',
            price: '4 990 ₽',
            duration: '60 минут',
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            context,
            name: 'Замена аккумулятора',
            description: 'Оригинальная батарея Apple',
            price: '2 490 ₽',
            duration: '45 минут',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String name,
    required String description,
    required String price,
    required String duration,
  }) {
    return GestureDetector(
      onTap: () => context.push('/booking/service_id'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.navigation),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTextStyles.navigation.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: const Text(
                    'Записаться',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
