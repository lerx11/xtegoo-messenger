import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Табы
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Row(
                children: [
                  _buildTab('Активные', 0),
                  _buildTab('Завершённые', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTab == 0 ? _buildActiveOrders() : _buildCompletedOrders(),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.image, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('iPhone 15 Pro Max', style: AppTextStyles.navigation),
                    const SizedBox(height: 4),
                    const Text('99 990 ₽', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'В обработке',
                        style: TextStyle(color: AppColors.warning, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedOrders() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text('Завершённых заказов нет', style: AppTextStyles.body),
        ],
      ),
    );
  }
}
