import 'package:commute_calendar/core/services/holiday_service.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.records,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Map<DateTime, WorkRecord> records;
  final void Function(DateTime month) onMonthChanged;
  final void Function(DateTime date) onDateSelected;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  Map<DateTime, String> _holidays = {};

  @override
  void initState() {
    super.initState();
    _loadHolidays(widget.focusedMonth.year);
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth.year != widget.focusedMonth.year) {
      _loadHolidays(widget.focusedMonth.year);
    }
  }

  Future<void> _loadHolidays(int year) async {
    final holidays = await HolidayService.getKoreanHolidays(year);
    if (mounted) setState(() => _holidays = holidays);
  }

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  WorkRecord? _recordFor(DateTime day) => widget.records[_normalize(day)];

  bool _isApiHoliday(DateTime day) => HolidayService.isHoliday(day, _holidays);

  bool _isWeekendOrHoliday(DateTime day) {
    final record = _recordFor(day);
    return day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday ||
        _isApiHoliday(day) ||
        record?.type == WorkType.holiday;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime(2020),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: widget.focusedMonth,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      availableGestures: AvailableGestures.horizontalSwipe,
      headerVisible: false,
      daysOfWeekHeight: 36,
      rowHeight: 68.0,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
      holidayPredicate: (day) => _isApiHoliday(day),
      onDaySelected: (selected, focused) => widget.onDateSelected(selected),
      onPageChanged: widget.onMonthChanged,
      daysOfWeekStyle: _buildDaysOfWeekStyle(),
      calendarStyle: _buildCalendarStyle(),
      calendarBuilders: _buildCalendarBuilders(),
    );
  }

  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      defaultBuilder: (ctx, day, _) => _buildCell(day),
      todayBuilder: (ctx, day, _) => _buildCell(day, isToday: true),
      selectedBuilder: (ctx, day, _) => _buildCell(
        day,
        isSelected: true,
        isToday: isSameDay(day, DateTime.now()),
      ),
      holidayBuilder: (ctx, day, _) => _buildCell(day),
      outsideBuilder: (ctx, day, _) => _buildCell(day, isOutside: true),
    );
  }

  Widget _buildCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final record = _recordFor(day);
    final isWeekendOrHol = _isWeekendOrHoliday(day);
    final holidayName = _isApiHoliday(day) && !isOutside
        ? HolidayService.getHolidayName(day, _holidays)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildDateCircle(
            day,
            record: record,
            isToday: isToday,
            isSelected: isSelected,
            isWeekendOrHol: isWeekendOrHol,
            isOutside: isOutside,
          ),
          const SizedBox(height: 3),
          if (!isOutside) _buildCellLabel(record, holidayName),
        ],
      ),
    );
  }

  Widget _buildDateCircle(
    DateTime day, {
    required WorkRecord? record,
    required bool isToday,
    required bool isSelected,
    required bool isWeekendOrHol,
    required bool isOutside,
  }) {
    Color bgColor = Colors.transparent;
    Color textColor;
    FontWeight fontWeight = FontWeight.w400;

    if (isToday) {
      bgColor = ThemeService.primary;
      textColor = ThemeService.white;
      fontWeight = FontWeight.w600;
    } else if (isSelected) {
      bgColor = ThemeService.black500;
      textColor = ThemeService.white;
      fontWeight = FontWeight.w600;
    } else if (isOutside) {
      textColor = ThemeService.black400;
    } else if (isWeekendOrHol) {
      // 공휴일·주말은 근무 기록 여부와 무관하게 secondary 우선
      // (하단 duration 텍스트로 근무 여부를 별도 표시)
      textColor = ThemeService.secondary;
    } else if (record?.type == WorkType.work) {
      textColor = ThemeService.primary;
    } else if (record?.type == WorkType.vacation) {
      textColor = ThemeService.vacation;
    } else if (record?.type == WorkType.holiday) {
      textColor = ThemeService.secondary;
    } else {
      textColor = ThemeService.black900;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Center(
        child: Text(
          '${day.day}',
          style: ThemeService.body2.copyWith(
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Widget _buildCellLabel(WorkRecord? record, String? holidayName) {
    if (record != null) {
      return switch (record.type) {
        WorkType.work => Text(
          _formatDuration(record.workedDuration),
          style: ThemeService.timeDisplay.copyWith(color: ThemeService.primary),
          textAlign: TextAlign.center,
        ),
        WorkType.vacation => _buildDot(ThemeService.vacation),
        WorkType.holiday => _buildDot(ThemeService.secondary),
      };
    }

    if (holidayName != null) return _buildDot(ThemeService.secondary);

    return const SizedBox.shrink();
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle() {
    final baseStyle = ThemeService.body2.copyWith(color: ThemeService.black600);
    return DaysOfWeekStyle(
      weekdayStyle: baseStyle,
      weekendStyle: baseStyle.copyWith(color: ThemeService.secondary),
      decoration: const BoxDecoration(color: ThemeService.white),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      outsideDaysVisible: false,
      defaultTextStyle: ThemeService.body2,
      weekendTextStyle: ThemeService.body2.copyWith(
        color: ThemeService.secondary,
      ),
      holidayTextStyle: ThemeService.body2.copyWith(
        color: ThemeService.secondary,
      ),
      holidayDecoration: const BoxDecoration(),
      outsideTextStyle: ThemeService.body2.copyWith(
        color: ThemeService.black400,
      ),
      todayDecoration: const BoxDecoration(),
      todayTextStyle: ThemeService.body2,
      selectedDecoration: const BoxDecoration(),
      selectedTextStyle: ThemeService.body2,
      markersMaxCount: 0,
      tableBorder: const TableBorder(
        horizontalInside: BorderSide(color: ThemeService.black200),
      ),
    );
  }
}
