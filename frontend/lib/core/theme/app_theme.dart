import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

// Радиусы дизайн-системы
class AppRadius {
  static const double chip = 8;
  static const double search = 12;
  static const double input = 16;
  static const double button = 18;
  static const double card = 20;
  static const double bottomSheet = 28;
  static const double avatar = 9999;
  static const double translation = 12;
}

// Отступы
class AppPadding {
  static const double screen = 20;
  static const double buttonHorizontal = 20;
  static const double inputHorizontal = 16;
  static const double inputVertical = 14;
}

// Размеры
class AppSizes {
  static const double buttonHeight = 52;
  static const double iconSize = 24;
  static const double smallIcon = 20;
  static const double avatarSmall = 40;
  static const double avatarMedium = 56;
  static const double avatarLarge = 100;
  static const double storySize = 72;
  static const double storyBorderWidth = 2.5;
}

// Тема приложения
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.background,
        error: AppColors.error,
      ),
      // Текст
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        titleLarge: AppTextStyles.screenTitle,
        titleMedium: AppTextStyles.navigation,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.secondary,
        bodySmall: AppTextStyles.caption,
        labelSmall: AppTextStyles.small,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.screenTitle,
      ),
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.small,
        unselectedLabelStyle: AppTextStyles.small,
      ),
      // Поля ввода
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondarySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppPadding.inputHorizontal,
          vertical: AppPadding.inputVertical,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.placeholder),
      ),
      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.buttonHorizontal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.navigation,
        ),
      ),
      // Разделители
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
