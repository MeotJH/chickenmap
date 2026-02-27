import 'package:flutter/material.dart';
import 'package:front/core/constants/app_colors.dart';

// 치킨맵 앱의 테마를 정의한다.
class AppTheme {
  // 라이트 테마만 우선 제공한다.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Public Sans',
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.chipBackground,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: AppColors.textPrimary),
    ),
  );
}
