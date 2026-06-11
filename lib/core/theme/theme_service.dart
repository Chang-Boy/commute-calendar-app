import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();

  // ─── Colors ───────────────────────────────────────────────────────────────

  // Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryDark = Color(0xFF1E40AF);

  // Secondary
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFD1FAE5);
  static const Color secondaryDark = Color(0xFF059669);

  // Neutral
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Calendar specific
  static const Color weekendText = Color(0xFFEF4444);
  static const Color holidayBg = Color(0xFFFEE2E2);
  static const Color selectedDayBg = Color(0xFF2563EB);
  static const Color selectedDayText = Color(0xFFFFFFFF);
  static const Color todayBorder = Color(0xFF2563EB);

  // Work hours indicator
  static const Color workComplete = Color(0xFF10B981);
  static const Color workIncomplete = Color(0xFFFCA5A5);
  static const Color workPartial = Color(0xFFFCD34D);

  // ─── Text Styles ──────────────────────────────────────────────────────────

  static const TextStyle title1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle subtitle3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  // Calendar specific
  static const TextStyle calendarDay = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle calendarDayWeekend = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: weekendText,
  );

  static const TextStyle calendarDaySelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: selectedDayText,
  );

  // ─── Text Style Helpers ───────────────────────────────────────────────────

  static TextStyle withSecondary(TextStyle base) =>
      base.copyWith(color: textSecondary);

  static TextStyle withTertiary(TextStyle base) =>
      base.copyWith(color: textTertiary);

  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}
