import 'package:flutter/material.dart';
import 'theme_service.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ThemeService.background,
      primaryColor: ThemeService.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeService.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ThemeService.title3.copyWith(
          color: ThemeService.textPrimary,
        ),
        iconTheme: const IconThemeData(color: ThemeService.textPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: ThemeService.title1,
        displayMedium: ThemeService.title2,
        displaySmall: ThemeService.title3,
        headlineLarge: ThemeService.subtitle1,
        headlineMedium: ThemeService.subtitle2,
        headlineSmall: ThemeService.subtitle3,
        bodyLarge: ThemeService.body1,
        bodyMedium: ThemeService.body2,
        bodySmall: ThemeService.body3,
        titleLarge: ThemeService.subtitle1,
        titleMedium: ThemeService.subtitle2,
        titleSmall: ThemeService.subtitle3,
        labelLarge: ThemeService.body1,
        labelMedium: ThemeService.body2,
        labelSmall: ThemeService.body3,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeService.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: ThemeService.subtitle3.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeService.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: ThemeService.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeService.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeService.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeService.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeService.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeService.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeService.error, width: 2),
        ),
        hintStyle: ThemeService.withSecondary(ThemeService.body1),
        labelStyle: ThemeService.body2.copyWith(
          color: ThemeService.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ThemeService.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: ThemeService.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: ThemeService.border),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: ThemeService.primary,
        onPrimary: Colors.white,
        secondary: ThemeService.secondary,
        onSecondary: Colors.white,
        surface: ThemeService.surface,
        onSurface: ThemeService.textPrimary,
        error: ThemeService.error,
        onError: Colors.white,
      ),
    );
  }
}
