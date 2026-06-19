import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WorkRecordCommutePicker extends StatelessWidget {
  const WorkRecordCommutePicker({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.startHourCtrl,
    required this.startMinCtrl,
    required this.endHourCtrl,
    required this.endMinCtrl,
    required this.onStartHourChanged,
    required this.onStartMinChanged,
    required this.onEndHourChanged,
    required this.onEndMinChanged,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final FixedExtentScrollController startHourCtrl;
  final FixedExtentScrollController startMinCtrl;
  final FixedExtentScrollController endHourCtrl;
  final FixedExtentScrollController endMinCtrl;
  final void Function(int) onStartHourChanged;
  final void Function(int) onStartMinChanged;
  final void Function(int) onEndHourChanged;
  final void Function(int) onEndMinChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToggleButton(),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildPickers(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    final color = isExpanded ? ThemeService.primary : ThemeService.black500;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(PhosphorIcons.clock(), color: color, size: 16),
            const SizedBox(width: 6),
            Text('출퇴근 시간 입력 (선택)', style: ThemeService.caption),
            const SizedBox(width: 4),
            PhosphorIcon(
              isExpanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
              color: color,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickers() {
    return Row(
      children: [
        Expanded(
          child: _SingleTimePicker(
            label: '출근',
            hourCtrl: startHourCtrl,
            minCtrl: startMinCtrl,
            onHourChanged: onStartHourChanged,
            onMinChanged: onStartMinChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SingleTimePicker(
            label: '퇴근',
            hourCtrl: endHourCtrl,
            minCtrl: endMinCtrl,
            onHourChanged: onEndHourChanged,
            onMinChanged: onEndMinChanged,
          ),
        ),
      ],
    );
  }
}

class _SingleTimePicker extends StatelessWidget {
  const _SingleTimePicker({
    required this.label,
    required this.hourCtrl,
    required this.minCtrl,
    required this.onHourChanged,
    required this.onMinChanged,
  });

  final String label;
  final FixedExtentScrollController hourCtrl;
  final FixedExtentScrollController minCtrl;
  final void Function(int) onHourChanged;
  final void Function(int) onMinChanged;

  @override
  Widget build(BuildContext context) {
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
}
