import 'package:commute_calendar/core/services/holiday_service.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_event.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_state.dart';
import 'package:commute_calendar/feature/common/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      buildWhen: (prev, curr) => curr is CalendarLoaded,
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
  final Map<DateTime, WorkRecordEntity> records;
  final Map<DateTime, String> holidays;

  @override
  Widget build(BuildContext context) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final record = records[normalizedDate];
    final isWeekend = _isWeekend(normalizedDate);

    return Container(
      color: ThemeService.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              _DateHeader(
                date: normalizedDate,
                holidays: holidays,
                isWeekend: isWeekend,
                hasHolidayRecord: record?.type == WorkType.holiday,
              ),
              if (record != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: _DeleteButton(recordId: record.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (record != null)
            _RecordTile(record: record)
          else
            _EmptyRecordText(
              holidayName: HolidayService.getHolidayName(normalizedDate, holidays),
              date: normalizedDate,
              isWeekend: isWeekend,
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
    required this.holidays,
    required this.isWeekend,
    required this.hasHolidayRecord,
  });

  final DateTime date;
  final Map<DateTime, String> holidays;
  final bool isWeekend;
  final bool hasHolidayRecord;

  @override
  Widget build(BuildContext context) {
    final holidayName = HolidayService.getHolidayName(date, holidays);
    // 공휴일 기록이 있거나, API 공휴일이거나, 주말이면 secondary 색상 적용
    final isSpecialDay = hasHolidayRecord || holidayName != null || isWeekend;
    final dateColor = isSpecialDay
        ? ThemeService.secondary
        : ThemeService.black900;

    final label = DateFormat('M월 d일 EEEE', 'ko_KR').format(date);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: ThemeService.body2.copyWith(color: dateColor),
        ),
        if (holidayName != null) ...[
          const SizedBox(height: 2),
          Text(
            holidayName,
            textAlign: TextAlign.center,
            style: ThemeService.caption.copyWith(color: ThemeService.secondary),
          ),
        ],
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final WorkRecordEntity record;

  Color get _accentColor => switch (record.type) {
    WorkType.work => ThemeService.primary,
    WorkType.vacation => ThemeService.vacation,
    WorkType.holiday => ThemeService.secondary,
  };

  PhosphorIconData get _icon => switch (record.type) {
    WorkType.work => PhosphorIcons.briefcase(),
    WorkType.vacation => PhosphorIcons.umbrella(),
    WorkType.holiday => PhosphorIcons.calendarX(),
  };

  String get _typeLabel => switch (record.type) {
    WorkType.work => '근무',
    WorkType.vacation => '연차',
    WorkType.holiday => '휴일',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ThemeService.black100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: _accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Record Type
                    _buildTypeHeader(),
                    const SizedBox(height: 4),

                    /// Record Detail
                    _buildMainContent(),

                    /// Memo
                    if (record.hasMemo) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.memo!,
                        style: ThemeService.caption.copyWith(
                          color: ThemeService.black500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeHeader() {
    return Row(
      children: [
        PhosphorIcon(_icon, color: _accentColor, size: 16),
        const SizedBox(width: 6),
        Text(
          _typeLabel,
          style: ThemeService.body2.copyWith(color: _accentColor),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return switch (record.type) {
      WorkType.work => _buildWorkContent(),
      WorkType.vacation => SizedBox(),
      WorkType.holiday => SizedBox(),
    };
  }

  Widget _buildWorkContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDuration(record.workedDuration),
          style: ThemeService.body1.copyWith(
            color: ThemeService.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (record.startTime != null && record.endTime != null) ...[
          const SizedBox(height: 4),
          Text(
            '${_formatTime(record.startTime!)}  ~  ${_formatTime(record.endTime!)}',
            style: ThemeService.body2.copyWith(color: ThemeService.black600),
          ),
        ],
      ],
    );
  }

  /// TODO: TimeUtil로 옮기기
  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) return '$hours시간';
    return '$hours시간 $minutes분';
  }
}

class _EmptyRecordText extends StatelessWidget {
  const _EmptyRecordText({
    required this.holidayName,
    required this.date,
    required this.isWeekend,
  });

  final String? holidayName;
  final DateTime date;
  final bool isWeekend;

  String get _text {
    if (holidayName != null) return holidayName!;
    if (isWeekend) return _weekdayText;
    return '근태 기록이 없어요!';
  }

  String get _weekdayText {
    const names = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return '${names[date.weekday - 1]}이에요';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: ThemeService.subtitle.copyWith(color: ThemeService.black300),
      textAlign: TextAlign.center,
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.recordId});

  final String recordId;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await CustomDialog.show(
      context: context,
      title: '기록 삭제',
      content: '이 날의 근태 기록을 삭제할까요?',
      confirmLabel: '삭제',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<CalendarBloc>().add(CalendarRecordDeleted(recordId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: PhosphorIcon(
          PhosphorIcons.trash(),
          color: ThemeService.secondary,
          size: 24,
        ),
      ),
    );
  }
}
