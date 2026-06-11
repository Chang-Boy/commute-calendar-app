import 'package:world_holidays/world_holidays.dart';

class HolidayService {
  HolidayService._();

  static final _worldHolidays = WorldHolidays();
  static final _cache = <int, Map<DateTime, String>>{};

  static Future<Map<DateTime, String>> getKoreanHolidays(int year) async {
    if (_cache.containsKey(year)) return _cache[year]!;

    final holidays = await _worldHolidays.getHolidays('KR', year: year);
    final map = {for (final h in holidays) _normalize(h.date): h.name};
    _cache[year] = map;
    return map;
  }

  static bool isHoliday(DateTime date, Map<DateTime, String> holidays) {
    return holidays.containsKey(_normalize(date));
  }

  static String? getHolidayName(DateTime date, Map<DateTime, String> holidays) {
    return holidays[_normalize(date)];
  }

  static DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
