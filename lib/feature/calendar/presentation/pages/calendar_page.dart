import 'package:commute_calendar/core/di/service_locator.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_event.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_state.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/calendar_widget.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/day_info_widget.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/monthly_summary_widget.dart';
import 'package:commute_calendar/feature/common/widgets/expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalendarBloc>(
      create: (_) =>
          getIt<CalendarBloc>()..add(CalendarMonthChanged(DateTime.now())),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _MonthHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const _CalendarLegend(),
                        BlocBuilder<CalendarBloc, CalendarState>(
                          builder: (context, state) {
                            if (state is! CalendarLoaded) {
                              return const SizedBox(
                                height: 480,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ThemeService.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return CalendarWidget(
                              focusedMonth: state.focusedMonth,
                              selectedDate: state.selectedDate,
                              records: state.records,
                              onMonthChanged: (month) => context
                                  .read<CalendarBloc>()
                                  .add(CalendarMonthChanged(month)),
                              onDateSelected: (date) => context
                                  .read<CalendarBloc>()
                                  .add(CalendarDateSelected(date)),
                            );
                          },
                        ),
                        const _SectionDivider(),
                        const MonthlySummaryWidget(),
                        const _SectionDivider(),
                        const DayInfoWidget(),
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: ExpandableFab(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _LegendItem(color: ThemeService.primary, label: '근무일'),
          const SizedBox(width: 20),
          _LegendItem(color: ThemeService.secondary, label: '휴일'),
          const SizedBox(width: 20),
          _LegendItem(color: ThemeService.vacation, label: '휴가'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: ThemeService.caption.copyWith(color: ThemeService.black600),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      color: ThemeService.black100,
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final month = state is CalendarLoaded
            ? state.focusedMonth
            : DateTime.now();
        final label = DateFormat('yyyy년 M월').format(month);

        return Container(
          color: ThemeService.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  final prev = DateTime(month.year, month.month - 1);
                  context.read<CalendarBloc>().add(CalendarMonthChanged(prev));
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: PhosphorIcon(
                    PhosphorIcons.caretLeft(),
                    color: ThemeService.black900,
                    size: 20,
                  ),
                ),
              ),
              Text(label, style: ThemeService.subtitle),
              GestureDetector(
                onTap: () {
                  final next = DateTime(month.year, month.month + 1);
                  context.read<CalendarBloc>().add(CalendarMonthChanged(next));
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: PhosphorIcon(
                    PhosphorIcons.caretRight(),
                    color: ThemeService.black900,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
