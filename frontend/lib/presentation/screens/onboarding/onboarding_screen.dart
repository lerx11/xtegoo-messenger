import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.chat_bubble,
      'title': 'Общайтесь без границ',
      'description': 'Мгновенные сообщения, голосовые и видео звонки',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.translate,
      'title': 'Встроенный переводчик',
      'description': 'Переводите сообщения на 100+ языков прямо в чате',
      'color': AppColors.primaryLight,
    },
    {
      'icon': Icons.store,
      'title': 'Маркетплейс и услуги',
      'description': 'Покупайте товары и записывайтесь на услуги',
      'color': AppColors.primaryDark,
    },
    {
      'icon': Icons.sim_card,
      'title': 'eSIM для путешествий',
      'description': 'Связь в любой точке мира',
      'color': AppColors.primary,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/auth/phone'),
                child: const Text('Пропустить'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppPadding.screen),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page['color'].withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'],
                            size: 60,
                            color: page['color'],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page['title'],
                          style: AppTextStyles.display,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'],
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Индикаторы
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == _pages.length - 1 ? 'Начать' : 'Далее'),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
