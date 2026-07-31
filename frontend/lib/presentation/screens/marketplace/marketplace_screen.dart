import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

// Тип элемента маркетплейса
enum ItemType { all, product, service }

// Сортировка
enum SortType { rating, priceAsc, priceDesc, newest }

class MarketplaceScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const MarketplaceScreen({super.key, this.categoryId});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ItemType _selectedType = ItemType.all;
  SortType _selectedSort = SortType.newest;
  String _selectedCategory = 'Все';
  int _page = 1;
  bool _isLoadingMore = false;
  final int _pageSize = 10;

  // Категории товаров и услуг
  final List<String> _productCategories = ['Все', 'Одежда', 'Электроника', 'Косметика', 'Handmade', 'Книги', 'Другое'];
  final List<String> _serviceCategories = ['Все', 'Визажист', 'Фотограф', 'Гид', 'Массажист', 'Парикмахер', 'Тренер', 'Психолог', 'Репетитор', 'Ветеринар', 'Клининг', 'Другое'];

  // Моковые данные товаров и услуг
  final List<Map<String, dynamic>> _allItems = [
    {'id': '1', 'type': 'product', 'name': 'iPhone 15 Pro Max', 'price': 99990, 'category': 'Электроника', 'seller': 'ТехноМир', 'image': '', 'rating': null, 'promoted': false},
    {'id': '2', 'type': 'product', 'name': 'Кроссовки Nike Air Max', 'price': 8990, 'category': 'Одежда', 'seller': 'СпортМаг', 'image': '', 'rating': null, 'promoted': true},
    {'id': '3', 'type': 'service', 'name': 'Массаж спины', 'price': 3500, 'category': 'Массажист', 'seller': 'Елена', 'image': '', 'rating': null, 'promoted': false},
    {'id': '4', 'type': 'product', 'name': 'Кофемашина DeLonghi', 'price': 45990, 'category': 'Электроника', 'seller': 'ДомТехника', 'image': '', 'rating': null, 'promoted': false},
    {'id': '5', 'type': 'service', 'name': 'Фотосессия в студии', 'price': 8000, 'category': 'Фотограф', 'seller': 'Максим', 'image': '', 'rating': null, 'promoted': true},
    {'id': '6', 'type': 'product', 'name': 'Наушники Sony WH-1000XM5', 'price': 24990, 'category': 'Электроника', 'seller': 'ЗвукПро', 'image': '', 'rating': null, 'promoted': false},
    {'id': '7', 'type': 'service', 'name': 'Стрижка мужская', 'price': 1500, 'category': 'Парикмахер', 'seller': 'Барбершоп', 'image': '', 'rating': null, 'promoted': false},
    {'id': '8', 'type': 'product', 'name': 'Шёлковая блузка', 'price': 5990, 'category': 'Одежда', 'seller': 'Boutique', 'image': '', 'rating': null, 'promoted': false},
    {'id': '9', 'type': 'service', 'name': 'Урок английского', 'price': 2000, 'category': 'Репетитор', 'seller': 'Анна', 'image': '', 'rating': null, 'promoted': false},
    {'id': '10', 'type': 'product', 'name': 'Натуральная косметика', 'price': 1990, 'category': 'Косметика', 'seller': 'EcoBeauty', 'image': '', 'rating': null, 'promoted': false},
    {'id': '11', 'type': 'product', 'name': 'Кожаный кошелёк ручной работы', 'price': 3500, 'category': 'Handmade', 'seller': 'CraftMaster', 'image': '', 'rating': null, 'promoted': false},
    {'id': '12', 'type': 'service', 'name': 'Тренировка с тренером', 'price': 2500, 'category': 'Тренер', 'seller': 'FitPro', 'image': '', 'rating': null, 'promoted': false},
  ];

  List<Map<String, dynamic>> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Подгрузка страниц (пагинация)
  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final filtered = _getFilteredItems();
    final endIndex = _page * _pageSize;

    if (endIndex < filtered.length) {
      setState(() {
        _displayedItems = filtered.sublist(0, endIndex.clamp(0, filtered.length));
        _page++;
        _isLoadingMore = false;
      });
    } else if (_displayedItems.length < filtered.length) {
      setState(() {
        _displayedItems = filtered;
        _isLoadingMore = false;
      });
    } else {
      setState(() => _isLoadingMore = false);
    }
  }

  // Фильтрация и сортировка
  List<Map<String, dynamic>> _getFilteredItems() {
    var items = List<Map<String, dynamic>>.from(_allItems);

    // Фильтр по типу
    if (_selectedType != ItemType.all) {
      items = items.where((i) => i['type'] == _selectedType.name).toList();
    }

    // Фильтр по категории
    if (_selectedCategory != 'Все') {
      items = items.where((i) => i['category'] == _selectedCategory).toList();
    }

    // Поиск
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      items = items.where((i) {
        return (i['name'] as String).toLowerCase().contains(query) ||
            (i['seller'] as String).toLowerCase().contains(query) ||
            (i['category'] as String).toLowerCase().contains(query);
      }).toList();
    }

    // Сортировка
    switch (_selectedSort) {
      case SortType.priceAsc:
        items.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case SortType.priceDesc:
        items.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
      case SortType.rating:
        // Заглушка — рейтинга пока нет
        break;
      case SortType.newest:
        break;
    }

    // Продвинутые — в топ
    items.sort((a, b) => (b['promoted'] as bool ? 1 : 0).compareTo(a['promoted'] as bool ? 1 : 0));

    return items;
  }

  // Обновить фильтры и сбросить пагинацию
  void _applyFilters() {
    setState(() {
      _page = 1;
      _displayedItems = [];
      _loadMore();
    });
  }

  // Текущий список категорий в зависимости от типа
  List<String> get _currentCategories {
    switch (_selectedType) {
      case ItemType.product:
        return _productCategories;
      case ItemType.service:
        return _serviceCategories;
      case ItemType.all:
        return ['Все', ..._productCategories.skip(1), ..._serviceCategories.skip(1)]
            .toSet()
            .toList();
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: const InputDecoration(
                hintText: 'Поиск товаров и услуг',
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                suffixIcon: Icon(Icons.tune, color: AppColors.textTertiary),
              ),
            ),
          ),

          // Фильтры: тип (Товары / Услуги / Все)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
            child: Row(
              children: [
                _buildTypeChip('Все', ItemType.all),
                const SizedBox(width: 8),
                _buildTypeChip('Товары', ItemType.product),
                const SizedBox(width: 8),
                _buildTypeChip('Услуги', ItemType.service),
                const Spacer(),
                // Кнопка фильтров
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _selectedSort == SortType.newest ? 'Новые' :
                          _selectedSort == SortType.priceAsc ? 'Цена ↑' :
                          _selectedSort == SortType.priceDesc ? 'Цена ↓' : 'Рейтинг',
                          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Категории — горизонтальный скролл
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
              itemCount: _currentCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _currentCategories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _applyFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      cat,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Сетка карточек
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _displayedItems.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _displayedItems.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildItemCard(_displayedItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Чип выбора типа
  Widget _buildTypeChip(String label, ItemType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = 'Все';
        });
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Карточка товара/услуги
  Widget _buildItemCard(Map<String, dynamic> item) {
    final isProduct = item['type'] == 'product';

    return GestureDetector(
      onTap: () {
        if (isProduct) {
          context.push('/product/${item['id']}');
        } else {
          context.push('/booking/${item['id']}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                  ),
                  child: const Icon(Icons.image, size: 48, color: AppColors.textTertiary),
                ),
                // Иконка типа (товар/услуга)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Icon(
                      isProduct ? Icons.shopping_bag_outlined : Icons.design_services_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Бейдж продвижения (заглушка)
                if (item['promoted'] == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: const Text(
                        'ТОП',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            // Инфо
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['price']} ₽',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  // Рейтинг — заглушка
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.translationBubble,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_outline, size: 12, color: AppColors.translationText),
                        const SizedBox(width: 2),
                        Text(
                          'Скоро',
                          style: AppTextStyles.small.copyWith(color: AppColors.translationText, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['seller'],
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

  // Bottom sheet с фильтрами
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(AppPadding.screen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Сортировка', style: AppTextStyles.navigation),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: SortType.values.map((sort) {
                    final isSelected = _selectedSort == sort;
                    final labels = {
                      SortType.newest: 'Новые',
                      SortType.priceAsc: 'Цена ↑',
                      SortType.priceDesc: 'Цена ↓',
                      SortType.rating: 'По рейтингу',
                    };
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() => _selectedSort = sort);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          labels[sort]!,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Заглушка для будущего функционала
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.translationBubble,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 20, color: AppColors.translationText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Внутренний кошелёк и продвижение — скоро',
                          style: AppTextStyles.caption.copyWith(color: AppColors.translationText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    child: const Text('Применить'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
