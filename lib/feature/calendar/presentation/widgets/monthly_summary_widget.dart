import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/domain/usecases/calculate_monthly_stats_usecase.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlySummaryWidget extends StatelessWidget {
  const MonthlySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state is! CalendarLoaded) return const SizedBox.shrink();
        return _SummaryContent(stats: state.stats);
      },
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeService.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: '총 목표',
            duration: stats.totalRequired,
          ),
          _Divider(),
          _SummaryItem(
            label: '현재 채움',
            duration: stats.totalWorked,
          ),
          _Divider(),
          _SummaryItem(
            label: '남은 시간',
            duration: stats.remaining,
            highlight: stats.remaining == Duration.zero,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.duration,
    this.highlight = false,
  });

  final String label;
  final Duration duration;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? ThemeService.vacation : ThemeService.black900;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: ThemeService.caption),
        const SizedBox(height: 4),
        Text(
          _format(duration),
          style: ThemeService.heading3.copyWith(color: color),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: ThemeService.black200,
    );
  }
}
