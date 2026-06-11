import 'package:flutter/material.dart';
import 'package:commute_calendar/feature/calendar/presentation/widgets/calendar_widget.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Expanded(
              child: SingleChildScrollView(
                child: CalendarWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: ThemeService.surface,
      child: Text(
        '근태 관리',
        style: ThemeService.title2,
      ),
    );
  }
}
