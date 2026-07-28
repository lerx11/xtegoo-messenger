import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _currentImage = 0;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _isLiked = !_isLiked);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.secondarySurface,
                child: const Icon(Icons.image, size: 100, color: AppColors.textTertiary),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'iPhone 15 Pro Max 256GB',
                    style: AppTextStyles.display,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '99 990 ₽',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSellerCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Описание',
                    style: AppTextStyles.navigation,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Новый iPhone 15 Pro Max с чипом A17 Pro, титановым корпусом и системой камер Pro. Самый инновационный iPhone в истории.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Характеристики',
                    style: AppTextStyles.navigation,
                  ),
                  const SizedBox(height: 8),
                  _buildSpecRow('Дисплей', '6.7" Super Retina XDR'),
                  _buildSpecRow('Процессор', 'A17 Pro'),
                  _buildSpecRow('Память', '256GB'),
                  _buildSpecRow('Камера', '48MP основная'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.screen),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/chat/product_${widget.productId}');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: const Text('Написать продавцу'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                  ),
                  child: const Text('Купить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerCard() {
    return GestureDetector(
      onTap: () => context.push('/business/seller_1'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.background,
              child: Icon(Icons.store, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ТехноМир', style: AppTextStyles.navigation),
                  Text('Продавец', style: AppTextStyles.small),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.secondary),
        ],
      ),
    );
  }
}
