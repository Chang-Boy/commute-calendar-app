import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_event.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_state.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/work_record_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  Future<void> _onMiniFabTapped(
      BuildContext context, WorkType workType) async {
    _close();

    final bloc = context.read<CalendarBloc>();
    final state = bloc.state;
    if (state is! CalendarLoaded) return;

    final selectedDate = state.selectedDate;
    final normalizedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final existingRecord = state.records[normalizedDate];

    final result = await WorkRecordBottomSheet.show(
      context: context,
      selectedDate: selectedDate,
      workType: workType,
      existingRecord: existingRecord,
    );

    if (result != null && context.mounted) {
      if (existingRecord != null) {
        bloc.add(CalendarRecordUpdated(result));
      } else {
        bloc.add(CalendarRecordAdded(result));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ..._buildMiniFabs(context),
              const SizedBox(height: 12),
              _buildMainFab(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMiniFabs(BuildContext context) {
    final items = [
      _MiniFabItem(
        label: '근무',
        icon: PhosphorIcons.briefcase(),
        color: ThemeService.primary,
        workType: WorkType.work,
      ),
      _MiniFabItem(
        label: '연차',
        icon: PhosphorIcons.umbrella(),
        color: ThemeService.vacation,
        workType: WorkType.vacation,
      ),
      _MiniFabItem(
        label: '휴일',
        icon: PhosphorIcons.calendarX(),
        color: ThemeService.secondary,
        workType: WorkType.holiday,
      ),
    ];

    return items.reversed.map((item) {
      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1.0 - _expandAnimation.value) * 16),
            child: Opacity(
              opacity: _expandAnimation.value,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMiniFabRow(context, item),
        ),
      );
    }).toList();
  }

  Widget _buildMiniFabRow(BuildContext context, _MiniFabItem item) {
    return GestureDetector(
      onTap: () => _onMiniFabTapped(context, item.workType),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ThemeService.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(item.label, style: ThemeService.caption),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: PhosphorIcon(
                item.icon,
                color: ThemeService.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFab() {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _expandAnimation.value * 0.785398, // 45도
            child: child,
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ThemeService.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: PhosphorIcon(
              PhosphorIcons.plus(),
              color: ThemeService.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniFabItem {
  const _MiniFabItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.workType,
  });

  final String label;
  final PhosphorIconData icon;
  final Color color;
  final WorkType workType;
}
