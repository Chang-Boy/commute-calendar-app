import 'package:commute_calendar/core/services/holiday_service.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DayInfoWidget extends StatefulWidget {
  const DayInfoWidget({super.key});

  @override
  State<DayInfoWidget> createState() => _DayInfoWidgetState();
}

class _DayInfoWidgetState extends State<DayInfoWidget> {
  Map<DateTime, String> _holidays = {};
  int _loadedYear = 0;

  @override
  void initState() {
    super.initState();
    _loadHolidays(DateTime.now().year);
  }

  // 연도가 바뀌면 해당 연도의 공휴일 데이터 재로드
  Future<void> _loadHolidays(int year) async {
    if (_loadedYear == year) return;
    final holidays = await HolidayService.getKoreanHolidays(year);
    if (mounted) {
      setState(() {
        _holidays = holidays;
        _loadedYear = year;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state is! CalendarLoaded) return const SizedBox.shrink();

        // focusedMonth 연도가 바뀌면 공휴일 재로드
        final year = state.focusedMonth.year;
        if (_loadedYear != year) {
          _loadHolidays(year);
        }

        return _DayInfoContent(
          selectedDate: state.selectedDate,
          records: state.records,
          holidays: _holidays,
        );
      },
    );
  }
}

class _DayInfoContent extends StatelessWidget {
  const _DayInfoContent({
    required this.selectedDate,
    required this.records,
    required this.holidays,
  });

  final DateTime selectedDate;
  final Map<DateTime, WorkRecord> records;
  final Map<DateTime, String> holidays;

  @override
  Widget build(BuildContext context) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final record = records[normalizedDate];
    final holidayName = HolidayService.getHolidayName(normalizedDate, holidays);
    final isWeekend = _isWeekend(normalizedDate);

    return Container(
      color: ThemeService.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateHeader(
            date: normalizedDate,
            holidayName: holidayName,
            isWeekend: isWeekend,
            hasHolidayRecord: record?.type == WorkType.holiday,
          ),
          const SizedBox(height: 8),
          _StatusMessage(
            record: record,
            holidayName: holidayName,
            isWeekend: isWeekend,
            date: normalizedDate,
          ),
        ],
      ),
    );
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.date,
    required this.holidayName,
    required this.isWeekend,
    required this.hasHolidayRecord,
  });

  final DateTime date;
  final String? holidayName;
  final bool isWeekend;
  final bool hasHolidayRecord;

  @override
  Widget build(BuildContext context) {
    // 공휴일 기록이 있거나, API 공휴일이거나, 주말이면 secondary 색상 적용
    final isSpecialDay = hasHolidayRecord || holidayName != null || isWeekend;
    final dateColor = isSpecialDay
        ? ThemeService.secondary
        : ThemeService.black900;

    final label = DateFormat('M월 d일 EEEE', 'ko_KR').format(date);

    return Text(
      label,
      textAlign: TextAlign.center,
      style: ThemeService.body2.copyWith(color: dateColor),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.record,
    required this.holidayName,
    required this.isWeekend,
    required this.date,
  });

  final WorkRecord? record;
  final String? holidayName;
  final bool isWeekend;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final message = _resolveMessage();
    final color = _resolveColor();

    return Column(
      children: [
        Text(message, style: ThemeService.headline.copyWith(color: color)),
        if (_shouldShowMemo && record?.memo != null && record!.memo!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              record!.memo!,
              style: ThemeService.body2.copyWith(color: ThemeService.black500),
            ),
          ),
      ],
    );
  }

  bool get _shouldShowMemo =>
      record?.type == WorkType.vacation || record?.type == WorkType.holiday;

  // 우선순위에 따라 메시지 결정
  String _resolveMessage() {
    // 1순위: WorkType.holiday 기록
    if (record?.type == WorkType.holiday) return '오늘은 휴일이에요!';

    // 2순위: WorkType.vacation 기록
    if (record?.type == WorkType.vacation) return '오늘은 휴가에요!';

    // 3순위: WorkType.work 기록
    if (record?.type == WorkType.work) {
      return '${_formatDuration(record!.workedDuration)} 근무했어요!';
    }

    // 4순위: API 공휴일
    if (holidayName != null) return '오늘은 $holidayName이에요!';

    // 5순위: 주말
    if (isWeekend) return '오늘은 ${_weekdayLabel(date.weekday)}이에요!';

    // 6순위: 기록 없는 평일
    return '근무 기록이 없어요!';
  }

  // 우선순위에 따라 색상 결정
  Color _resolveColor() {
    if (record?.type == WorkType.holiday) return ThemeService.black700;
    if (record?.type == WorkType.vacation) return ThemeService.vacation;
    if (record?.type == WorkType.work) return ThemeService.primary;
    if (holidayName != null) return ThemeService.secondary;
    if (isWeekend) return ThemeService.secondary;
    return ThemeService.black400;
  }

  // Duration → "9시간 11분" / "9시간" (분이 0이면 분 생략)
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) return '$hours시간';
    return '$hours시간 $minutes분';
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => '월요일',
      DateTime.tuesday => '화요일',
      DateTime.wednesday => '수요일',
      DateTime.thursday => '목요일',
      DateTime.friday => '금요일',
      DateTime.saturday => '토요일',
      DateTime.sunday => '일요일',
      _ => '알 수 없음',
    };
  }
}
