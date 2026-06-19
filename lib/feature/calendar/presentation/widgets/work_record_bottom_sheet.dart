import 'package:commute_calendar/core/services/toast_service.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/work_record_commute_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final WorkRecordEntity? existingRecord;

  static Future<WorkRecordEntity?> show({
    required BuildContext context,
    required DateTime selectedDate,
    required WorkType workType,
    WorkRecordEntity? existingRecord,
  }) {
    return showModalBottomSheet<WorkRecordEntity>(
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
  // 근무시간 (필수, work 타입에서만 사용)
  late int _durationHours;
  late int _durationMinutes;

  // 출퇴근 시간 (선택, 인라인 펼침)
  bool _isTimeExpanded = false;
  late int _startHour;
  late int _startMinute;
  late int _endHour;
  late int _endMinute;
  late FixedExtentScrollController _startHourCtrl;
  late FixedExtentScrollController _startMinCtrl;
  late FixedExtentScrollController _endHourCtrl;
  late FixedExtentScrollController _endMinCtrl;

  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingRecord?.type == WorkType.work
        ? widget.existingRecord
        : null;

    // 근무시간 복원
    final existingMinutes = existing?.workMinutes ?? 0;
    _durationHours = existingMinutes ~/ 60;
    _durationMinutes = existingMinutes % 60;

    // 출퇴근 시간 복원 (기존 기록에 출퇴근 있으면 펼쳐서 표시)
    final startTime =
        existing?.startTime ?? const TimeOfDay(hour: 8, minute: 30);
    final endTime = existing?.endTime ?? const TimeOfDay(hour: 17, minute: 30);
    _startHour = startTime.hour;
    _startMinute = startTime.minute;
    _endHour = endTime.hour;
    _endMinute = endTime.minute;
    _isTimeExpanded = existing?.startTime != null;

    _startHourCtrl = FixedExtentScrollController(initialItem: _startHour);
    _startMinCtrl = FixedExtentScrollController(initialItem: _startMinute);
    _endHourCtrl = FixedExtentScrollController(initialItem: _endHour);
    _endMinCtrl = FixedExtentScrollController(initialItem: _endMinute);

    _hoursController = TextEditingController(
      text: _durationHours > 0 ? _durationHours.toString() : '',
    );
    _minutesController = TextEditingController(
      text: _durationMinutes > 0 ? _durationMinutes.toString() : '',
    );

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
    _hoursController.dispose();
    _minutesController.dispose();
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

  bool get _canSave =>
      widget.workType != WorkType.work ||
      (_durationHours > 0 || _durationMinutes > 0);

  void _save() {
    if (widget.workType == WorkType.work &&
        _durationHours == 0 &&
        _durationMinutes == 0) {
      ToastService.show(
        context: context,
        message: '근무시간을 입력해주세요.',
        isError: true,
      );
      return;
    }

    final id =
        widget.existingRecord?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final memo = _memoController.text.trim();
    final workMinutes = _durationHours * 60 + _durationMinutes.clamp(0, 59);

    final record = WorkRecordEntity(
      id: id,
      date: widget.selectedDate,
      type: widget.workType,
      workMinutes: widget.workType == WorkType.work ? workMinutes : null,
      startTime: (widget.workType == WorkType.work && _isTimeExpanded)
          ? TimeOfDay(hour: _startHour, minute: _startMinute)
          : null,
      endTime: (widget.workType == WorkType.work && _isTimeExpanded)
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
            _buildDurationInput(),
            const SizedBox(height: 12),
            WorkRecordCommutePicker(
              isExpanded: _isTimeExpanded,
              onToggle: () =>
                  setState(() => _isTimeExpanded = !_isTimeExpanded),
              startHourCtrl: _startHourCtrl,
              startMinCtrl: _startMinCtrl,
              endHourCtrl: _endHourCtrl,
              endMinCtrl: _endMinCtrl,
              onStartHourChanged: (v) => setState(() => _startHour = v),
              onStartMinChanged: (v) => setState(() => _startMinute = v),
              onEndHourChanged: (v) => setState(() => _endHour = v),
              onEndMinChanged: (v) => setState(() => _endMinute = v),
            ),
            const SizedBox(height: 16),
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

  Widget _buildDurationInput() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            label: '시간',
            controller: _hoursController,
            onChanged: (v) =>
                setState(() => _durationHours = int.tryParse(v) ?? 0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeField(
            label: '분',
            controller: _minutesController,
            onChanged: (v) => setState(
              () => _durationMinutes = (int.tryParse(v) ?? 0).clamp(0, 59),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ThemeService.caption),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          style: ThemeService.body1,
          textAlign: TextAlign.center,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: ThemeService.body1.copyWith(
              color: ThemeService.black400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: ThemeService.black100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
    final isEnabled = _canSave;
    return GestureDetector(
      onTap: isEnabled ? _save : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isEnabled ? _accentColor : ThemeService.black300,
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
