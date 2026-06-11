import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/core/services/holiday_service.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> _holidays = {};

  @override
  void initState() {
    super.initState();
    _loadHolidays(_focusedDay.year);
  }

  Future<void> _loadHolidays(int year) async {
    final holidays = await HolidayService.getKoreanHolidays(year);
    if (mounted) {
      setState(() => _holidays = holidays);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _loadHolidays(focusedDay.year);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime(2020),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      holidayPredicate: (day) => HolidayService.isHoliday(day, _holidays),
      onDaySelected: _onDaySelected,
      onPageChanged: _onPageChanged,
      headerStyle: _buildHeaderStyle(),
      daysOfWeekStyle: _buildDaysOfWeekStyle(),
      calendarStyle: _buildCalendarStyle(),
      calendarBuilders: _buildCalendarBuilders(),
    );
  }

  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      holidayBuilder: (context, day, focusedDay) {
        final name = HolidayService.getHolidayName(day, _holidays);
        return _buildHolidayDayCell(day, name);
      },
    );
  }

  Widget _buildHolidayDayCell(DateTime day, String? holidayName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${day.day}',
          style: ThemeService.calendarDayWeekend,
        ),
        if (holidayName != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              holidayName,
              style: ThemeService.calendarDayWeekend.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  HeaderStyle _buildHeaderStyle() {
    return HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      titleTextStyle: ThemeService.title3,
      headerPadding: const EdgeInsets.symmetric(vertical: 12),
      leftChevronIcon: const Icon(
        Icons.chevron_left,
        color: ThemeService.textPrimary,
        size: 20,
      ),
      rightChevronIcon: const Icon(
        Icons.chevron_right,
        color: ThemeService.textPrimary,
        size: 20,
      ),
      decoration: const BoxDecoration(color: ThemeService.surface),
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: ThemeService.body3,
      weekendStyle: ThemeService.body3.copyWith(
        color: ThemeService.weekendText,
      ),
      decoration: const BoxDecoration(color: ThemeService.surface),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      outsideDaysVisible: false,
      // 기본 날짜
      defaultTextStyle: ThemeService.calendarDay,
      // 주말
      weekendTextStyle: ThemeService.calendarDayWeekend,
      // 공휴일 (평일 공휴일)
      holidayTextStyle: ThemeService.calendarDayWeekend,
      holidayDecoration: const BoxDecoration(shape: BoxShape.circle),
      // 이전/다음 달 날짜
      outsideTextStyle: ThemeService.withTertiary(ThemeService.calendarDay),
      // 오늘
      todayDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ThemeService.todayBorder, width: 1.5),
      ),
      todayTextStyle: ThemeService.calendarDay.copyWith(
        color: ThemeService.primary,
        fontWeight: FontWeight.w600,
      ),
      // 선택된 날짜
      selectedDecoration: const BoxDecoration(
        color: ThemeService.selectedDayBg,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: ThemeService.calendarDaySelected,
      // 이벤트 마커 비활성화 (추후 사용)
      markerDecoration: const BoxDecoration(
        color: ThemeService.primary,
        shape: BoxShape.circle,
      ),
      markersMaxCount: 0,
      tableBorder: const TableBorder(
        horizontalInside: BorderSide(color: ThemeService.divider),
      ),
    );
  }
}
