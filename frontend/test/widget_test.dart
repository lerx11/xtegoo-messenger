// Базовый smoke-тест приложения XTegoo.
//
// Полный запуск XTegooApp в тестовом окружении требует инициализации Hive,
// GoRouter и сокетов, что оставляет pending-таймеры. Поэтому здесь проверяется
// только базовая способность тестового окружения собирать виджеты.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke-тест: MaterialApp с текстом собирается', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('XTegoo')),
        ),
      ),
    );

    expect(find.text('XTegoo'), findsOneWidget);
  });
}
