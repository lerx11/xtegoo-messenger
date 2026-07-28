import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const MarketplaceScreen({super.key, this.categoryId});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Все';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Все', 'icon': Icons.grid_view, 'color': AppColors.primary},
    {'name': 'Электроника', 'icon': Icons.phone_iphone, 'color': Colors.blue},
    {'name': 'Одежда', 'icon': Icons.checkroom, 'color': Colors.pink},
    {'name': 'Дом', 'icon': Icons.home, 'color': Colors.orange},
    {'name': 'Красота', 'icon': Icons.face, 'color': Colors.purple},
    {'name': 'Спорт', 'icon': Icons.fitness_center, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'iPhone 15 Pro Max',
      'price': 99990,
      'images': [''],
      'seller': 'ТехноМир',
      'id': '1',
    },
    {
      'name': 'Кроссовки Nike Air Max',
      'price': 8990,
      'images': [''],
      'seller': 'СпортМаг',
      'id': '2',
    },
    {
      'name': 'Кофемашина DeLonghi',
      'price': 45990,
      'images': [''],
      'seller': 'ДомТехника',
      'id': '3',
    },
    {
      'name': 'Наушники Sony WH-1000XM5',
      'price': 24990,
      'images': [''],
      'seller': 'ЗвукПро',
      'id': '4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маркетплейс'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
            onPressed: () => context.push('/orders'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Поиск товаров',
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Категории
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat['name']);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (cat['color'] as Color).withOpacity(0.15)
                              : AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? cat['color'] : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? cat['color'] : AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['name'],
                        style: AppTextStyles.small.copyWith(
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Фильтры
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: Row(
              children: [
                const Text(
                  'Популярные',
                  style: AppTextStyles.navigation,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Фильтры'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Товары
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => context.push('/product/${product['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                ),
                child: const Icon(Icons.image, size: 60, color: AppColors.textTertiary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: AppTextStyles.secondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['price']} ₽',
                    style: AppTextStyles.navigation.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['seller'],
                    style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
