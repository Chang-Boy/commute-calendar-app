import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:commute_calendar/feature/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ThemeService.white,
      body: Center(
        child: Text(
          '근태 달력',
          style: ThemeService.headline,
        ),
      ),
    );
  }
}
