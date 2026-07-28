import 'package:flutter/material.dart';

// Типографика дизайн-системы XTegoo (системный шрифт SF Pro)
class AppTextStyles {
  static const String _fontFamily = 'SF Pro Display';

  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle screenTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle navigation = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle secondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle small = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle translation = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}
