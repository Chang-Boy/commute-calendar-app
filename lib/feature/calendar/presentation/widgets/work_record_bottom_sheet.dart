import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WorkRecordBottomSheet extends StatefulWidget {
  const WorkRecordBottomSheet({
    super.key,
    required this.selectedDate,
    required this.workType,
    this.existingRecord,
  });

  final DateTime selectedDate;
  final WorkType workType;
  final WorkRecord? existingRecord;

  static Future<WorkRecord?> show({
    required BuildContext context,
    required DateTime selectedDate,
    required WorkType workType,
    WorkRecord? existingRecord,
  }) {
    return showModalBottomSheet<WorkRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkRecordBottomSheet(
        selectedDate: selectedDate,
        workType: workType,
        existingRecord: existingRecord,
      ),
    );
  }

  @override
  State<WorkRecordBottomSheet> createState() => _WorkRecordBottomSheetState();
}

class _WorkRecordBottomSheetState extends State<WorkRecordBottomSheet> {
  late int _startHour;
  late int _startMinute;
  late int _endHour;
  late int _endMinute;
  late FixedExtentScrollController _startHourCtrl;
  late FixedExtentScrollController _startMinCtrl;
  late FixedExtentScrollController _endHourCtrl;
  late FixedExtentScrollController _endMinCtrl;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    // 기존 기록이 work 타입이면 해당 시간으로 초기화, 아니면 기본값
    final existing = widget.existingRecord?.type == WorkType.work
        ? widget.existingRecord
        : null;
    final startTime = existing?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    final endTime = existing?.endTime ?? TimeOfDay.now();

    _startHour = startTime.hour;
    _startMinute = startTime.minute;
    _endHour = endTime.hour;
    _endMinute = endTime.minute;

    _startHourCtrl = FixedExtentScrollController(initialItem: _startHour);
    _startMinCtrl = FixedExtentScrollController(initialItem: _startMinute);
    _endHourCtrl = FixedExtentScrollController(initialItem: _endHour);
    _endMinCtrl = FixedExtentScrollController(initialItem: _endMinute);

    final existingMemo = widget.existingRecord?.type == widget.workType
        ? widget.existingRecord?.memo
        : null;
    _memoController = TextEditingController(text: existingMemo ?? '');
  }

  @override
  void dispose() {
    _startHourCtrl.dispose();
    _startMinCtrl.dispose();
    _endHourCtrl.dispose();
    _endMinCtrl.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Color get _accentColor => switch (widget.workType) {
    WorkType.work => ThemeService.primary,
    WorkType.vacation => ThemeService.vacation,
    WorkType.holiday => ThemeService.secondary,
  };

  PhosphorIconData get _typeIcon => switch (widget.workType) {
    WorkType.work => PhosphorIcons.briefcase(),
    WorkType.vacation => PhosphorIcons.umbrella(),
    WorkType.holiday => PhosphorIcons.calendarX(),
  };

  Duration get _previewDuration {
    final startMin = _startHour * 60 + _startMinute;
    final endMin = _endHour * 60 + _endMinute;
    final diff = endMin - startMin;
    return diff > 0 ? Duration(minutes: diff) : Duration.zero;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  void _save() {
    final id = widget.existingRecord?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final memo = _memoController.text.trim();

    final record = WorkRecord(
      id: id,
      date: widget.selectedDate,
      type: widget.workType,
      startTime: widget.workType == WorkType.work
          ? TimeOfDay(hour: _startHour, minute: _startMinute)
          : null,
      endTime: widget.workType == WorkType.work
          ? TimeOfDay(hour: _endHour, minute: _endMinute)
          : null,
      memo: memo.isEmpty ? null : memo,
    );
    Navigator.pop(context, record);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeService.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildDateLabel(),
          const SizedBox(height: 24),
          if (widget.workType == WorkType.work) ...[
            _buildTimePickers(),
            const SizedBox(height: 16),
            _buildDurationPreview(),
            const SizedBox(height: 24),
          ],
          _buildMemoField(),
          const SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: ThemeService.black300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final titles = {
      WorkType.work: '근무 기록',
      WorkType.vacation: '연차',
      WorkType.holiday: '휴일',
    };
    return Row(
      children: [
        PhosphorIcon(_typeIcon, color: _accentColor, size: 22),
        const SizedBox(width: 8),
        Text(titles[widget.workType]!, style: ThemeService.subtitle),
      ],
    );
  }

  Widget _buildDateLabel() {
    final label = DateFormat('yyyy년 M월 d일').format(widget.selectedDate);
    return Text(
      label,
      style: ThemeService.body1.copyWith(color: ThemeService.black600),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildSinglePicker(
            label: '출근',
            hourCtrl: _startHourCtrl,
            minCtrl: _startMinCtrl,
            onHourChanged: (v) => setState(() => _startHour = v),
            onMinChanged: (v) => setState(() => _startMinute = v),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSinglePicker(
            label: '퇴근',
            hourCtrl: _endHourCtrl,
            minCtrl: _endMinCtrl,
            onHourChanged: (v) => setState(() => _endHour = v),
            onMinChanged: (v) => setState(() => _endMinute = v),
          ),
        ),
      ],
    );
  }

  Widget _buildSinglePicker({
    required String label,
    required FixedExtentScrollController hourCtrl,
    required FixedExtentScrollController minCtrl,
    required void Function(int) onHourChanged,
    required void Function(int) onMinChanged,
  }) {
    const pickerHeight = 130.0;
    const itemExtent = 38.0;
    const bg = ThemeService.black100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ThemeService.caption),
        const SizedBox(height: 6),
        Container(
          height: pickerHeight,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: hourCtrl,
                      itemExtent: itemExtent,
                      looping: true,
                      backgroundColor: Colors.transparent,
                      selectionOverlay: const SizedBox.shrink(),
                      onSelectedItemChanged: onHourChanged,
                      children: List.generate(
                        24,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: ThemeService.subtitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: ThemeService.body1.copyWith(
                      color: ThemeService.black500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: minCtrl,
                      itemExtent: itemExtent,
                      looping: true,
                      backgroundColor: Colors.transparent,
                      selectionOverlay: const SizedBox.shrink(),
                      onSelectedItemChanged: onMinChanged,
                      children: List.generate(
                        60,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: ThemeService.subtitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 위아래 그라디언트로 비선택 항목 페이드아웃
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [bg, Color(0x00F7F7F7), Color(0x00F7F7F7), bg],
                      stops: [0.0, 0.38, 0.62, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeService.black100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '근무 시간',
            style: ThemeService.body2.copyWith(color: ThemeService.black600),
          ),
          Text(
            _formatDuration(_previewDuration),
            style: ThemeService.subtitle.copyWith(color: _accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoField() {
    return TextField(
      controller: _memoController,
      maxLength: 100,
      maxLines: 2,
      style: ThemeService.body2,
      decoration: InputDecoration(
        hintText: _memoHint,
        hintStyle: ThemeService.body2.copyWith(color: ThemeService.black400),
        counterStyle: ThemeService.caption,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: ThemeService.black100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String get _memoHint => switch (widget.workType) {
    WorkType.work => '오늘 한 일을 요약해주세요. (선택)',
    WorkType.vacation => '어디로 휴가를 떠나시나요? (선택)',
    WorkType.holiday => '어떤 휴일인가요? (선택)',
  };

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '저장',
            style: ThemeService.body1.copyWith(
              color: ThemeService.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
