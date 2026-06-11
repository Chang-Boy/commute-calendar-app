import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
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
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    // 기존 기록이 work 타입이면 해당 시간으로 초기화, 아니면 기본값
    final existing = widget.existingRecord?.type == WorkType.work
        ? widget.existingRecord
        : null;
    _startTime = existing?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = existing?.endTime ?? const TimeOfDay(hour: 18, minute: 0);
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
    final startMin = _startTime.hour * 60 + _startTime.minute;
    final endMin = _endTime.hour * 60 + _endTime.minute;
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

    final record = WorkRecord(
      id: id,
      date: widget.selectedDate,
      type: widget.workType,
      startTime: widget.workType == WorkType.work ? _startTime : null,
      endTime: widget.workType == WorkType.work ? _endTime : null,
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
            _buildTimePickers(context),
            const SizedBox(height: 16),
            _buildDurationPreview(),
            const SizedBox(height: 24),
          ],
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
        Text(titles[widget.workType]!, style: ThemeService.heading3),
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

  Widget _buildTimePickers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimePickerField(
            label: '출근',
            time: _startTime,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (picked != null) setState(() => _startTime = picked);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimePickerField(
            label: '퇴근',
            time: _endTime,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (picked != null) setState(() => _endTime = picked);
            },
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
            style: ThemeService.heading3.copyWith(color: _accentColor),
          ),
        ],
      ),
    );
  }

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

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  String _fmt(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ThemeService.black100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeService.black200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: ThemeService.caption),
            const SizedBox(height: 4),
            Text(_fmt(time), style: ThemeService.heading3),
          ],
        ),
      ),
    );
  }
}
