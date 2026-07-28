import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class BusinessProfileScreen extends StatefulWidget {
  final String businessId;

  const BusinessProfileScreen({super.key, required this.businessId});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppPadding.screen),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.store, size: 40, color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ТехноМир',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Электроника и гаджеты',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 16),
                            SizedBox(width: 4),
                            Text('4.8 (234 отзыва)',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Кнопка записаться
                Padding(
                  padding: const EdgeInsets.all(AppPadding.screen),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Записаться'),
                    ),
                  ),
                ),
                // Табы
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
                  child: Row(
                    children: [
                      _buildTab('Услуги', 0),
                      _buildTab('Товары', 1),
                      _buildTab('Календарь', 2),
                      _buildTab('Отзывы', 3),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Контент таба
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
                  child: _buildTabContent(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) {
      return Column(
        children: [
          _buildServiceItem('Диагностика', 'Бесплатно', '30 мин'),
          _buildServiceItem('Ремонт экрана', '4 990 ₽', '60 мин'),
          _buildServiceItem('Замена батареи', '2 490 ₽', '45 мин'),
        ],
      );
    }
    if (_selectedTab == 1) {
      return const Text('Товары скоро появятся', style: AppTextStyles.body);
    }
    if (_selectedTab == 2) {
      return const Text('Расписание доступно', style: AppTextStyles.body);
    }
    return const Text('Отзывы', style: AppTextStyles.body);
  }

  Widget _buildServiceItem(String name, String price, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.navigation),
                const SizedBox(height: 4),
                Text(duration, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: AppTextStyles.navigation.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.push('/booking/service_1'),
                child: const Text('Записаться'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
