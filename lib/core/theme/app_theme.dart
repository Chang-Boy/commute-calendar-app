import 'package:flutter/material.dart';
import 'theme_service.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      fontFamily: 'Pretendard',
      brightness: Brightness.light,
      scaffoldBackgroundColor: ThemeService.black100,
      primaryColor: ThemeService.primary,
      colorScheme: ColorScheme.light(
        primary: ThemeService.primary,
        onPrimary: ThemeService.white,
        secondary: ThemeService.secondary,
        onSecondary: ThemeService.white,
        surface: ThemeService.white,
        onSurface: ThemeService.black900,
        error: ThemeService.secondary,
        onError: ThemeService.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeService.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ThemeService.heading3,
        iconTheme: const IconThemeData(color: ThemeService.black900),
      ),
      dividerTheme: const DividerThemeData(
        color: ThemeService.black200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
