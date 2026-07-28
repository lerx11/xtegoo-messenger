import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'xtegoo_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('translations');
  await Hive.openBox('auth');

  runApp(
    const ProviderScope(
      child: XTegooApp(),
    ),
  );
}
