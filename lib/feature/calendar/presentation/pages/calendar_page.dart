import 'package:commute_calendar/core/di/service_locator.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_event.dart';
import 'package:commute_calendar/feature/calendar/presentation/bloc/calendar_state.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/calendar_widget.dart';
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
      backgroundColor: ThemeService.black100,
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
                        const MonthlySummaryWidget(),
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
              Text(label, style: ThemeService.heading3),
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
