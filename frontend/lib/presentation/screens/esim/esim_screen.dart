import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class EsimScreen extends StatefulWidget {
  const EsimScreen({super.key});

  @override
  State<EsimScreen> createState() => _EsimScreenState();
}

class _EsimScreenState extends State<EsimScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCountry = 'Все страны';

  final List<Map<String, dynamic>> _plans = [
    {'country': 'Китай', 'flag': '🇨🇳', 'data': '10 ГБ', 'days': 7, 'price': 19.99, 'provider': 'Zetexa'},
    {'country': 'Китай', 'flag': '🇨🇳', 'data': '20 ГБ', 'days': 15, 'price': 35.99, 'provider': 'Airalo'},
    {'country': 'США', 'flag': '🇺🇸', 'data': '15 ГБ', 'days': 10, 'price': 29.99, 'provider': 'Zetexa'},
    {'country': 'Европа', 'flag': '🇪🇺', 'data': '10 ГБ', 'days': 7, 'price': 24.99, 'provider': 'Airalo'},
    {'country': 'Турция', 'flag': '🇹🇷', 'data': '8 ГБ', 'days': 7, 'price': 14.99, 'provider': 'Holafly'},
    {'country': 'Таиланд', 'flag': '🇹🇭', 'data': '15 ГБ', 'days': 8, 'price': 19.99, 'provider': 'Zetexa'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSIM'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Планы'),
            Tab(text: 'Мои eSIM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlansTab(),
          _buildMyEsimTab(),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return ListView(
      padding: const EdgeInsets.all(AppPadding.screen),
      children: [
        // Фильтр по стране
        const Text('Страна', style: AppTextStyles.navigation),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final countries = ['Все страны', 'Китай 🇨🇳', 'США 🇺🇸', 'Европа 🇪🇺', 'Турция 🇹🇷', 'Таиланд 🇹🇭', 'Япония 🇯🇵'];
              final isSelected = _selectedCountry == countries[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedCountry = countries[index]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    countries[index],
                    style: AppTextStyles.secondary.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text('Популярные тарифы', style: AppTextStyles.navigation),
        const SizedBox(height: 12),
        ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Text(plan['flag'], style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan['country'], style: AppTextStyles.navigation),
                const SizedBox(height: 4),
                Text(
                  '${plan['data']} • ${plan['days']} дней',
                  style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  plan['provider'],
                  style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${plan['price']}',
                style: AppTextStyles.navigation.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Купить', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyEsimTab() {
    return ListView(
      padding: const EdgeInsets.all(AppPadding.screen),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Zetexa', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Активна', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Китай • 10 ГБ / 7 дней', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('ICCID: 89860123456789012345', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Осталось', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        const Text('7.2 ГБ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.72,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('История', style: AppTextStyles.navigation),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              const Text('🇺🇸', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('США • 15 ГБ / 10 дней', style: AppTextStyles.navigation),
                    SizedBox(height: 4),
                    Text('Истёк 2 дня назад', style: AppTextStyles.small),
                  ],
                ),
              ),
              Text('\$29.99', style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
