import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();

  // ─── 유채색 ───────────────────────────────────────────────────────────────

  static const Color primary = Color(0xFF74B9FF);    // 스카이블루 (포커스, 선택)
  static const Color secondary = Color(0xFFFF6B47);  // 살몬 (강조, 공휴일)
  static const Color tertiary = Color(0xFFFFC547);   // 크림 (휴가)

  // ─── 무채색 ───────────────────────────────────────────────────────────────

  static const Color white = Color(0xFFFFFFFF);
  static const Color black100 = Color(0xFFF7F7F7);
  static const Color black200 = Color(0xFFEEEEEE);
  static const Color black300 = Color(0xFFE0E0E0);
  static const Color black400 = Color(0xFFBDBDBD);
  static const Color black500 = Color(0xFF9E9E9E);
  static const Color black600 = Color(0xFF757575);
  static const Color black700 = Color(0xFF616161);
  static const Color black800 = Color(0xFF424242);
  static const Color black900 = Color(0xFF212121);

  // ─── 텍스트 스타일 (Pretendard) ──────────────────────────────────────────

  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: black900,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: black900,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: black900,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: black900,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: black900,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 1.5,
    color: black700,
  );

  // 달력 셀 근무시간 표시용 (예: 9h 30m)
  static const TextStyle timeDisplay = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: black700,
  );

  // ─── 헬퍼 ────────────────────────────────────────────────────────────────

  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}
