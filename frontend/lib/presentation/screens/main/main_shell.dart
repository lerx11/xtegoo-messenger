import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/home/chats')) return 0;
    if (location.contains('/home/calls')) return 1;
    if (location.contains('/home/translate')) return 2;
    if (location.contains('/home/marketplace')) return 3;
    if (location.contains('/home/calendar')) return 4;
    if (location.contains('/home/settings')) return 5;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home/chats');
        break;
      case 1:
        context.go('/home/calls');
        break;
      case 2:
        context.go('/home/translate');
        break;
      case 3:
        context.go('/home/marketplace');
        break;
      case 4:
        context.go('/home/calendar');
        break;
      case 5:
        context.go('/home/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Чаты',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call_outlined),
              activeIcon: Icon(Icons.call),
              label: 'Звонки',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate),
              activeIcon: Icon(Icons.translate),
              label: 'Перевод',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Маркет',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Календарь',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
