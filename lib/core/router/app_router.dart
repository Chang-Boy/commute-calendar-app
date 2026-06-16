import 'dart:async';

import 'package:commute_calendar/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:commute_calendar/feature/auth/presentation/bloc/auth_state.dart';
import 'package:commute_calendar/feature/auth/presentation/pages/splash_page.dart';
import 'package:commute_calendar/feature/auth/presentation/sign_in/pages/sign_in_page.dart';
import 'package:commute_calendar/feature/calendar/presentation/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      if (authState is AuthInitial) {
        return location == '/splash' ? null : '/splash';
      }

      if (authState is AuthUnauthenticated) {
        return location == '/sign-in' ? null : '/sign-in';
      }

      if (authState is AuthAuthenticated) {
        final isOnAuthPage = location == '/splash' || location == '/sign-in';
        return isOnAuthPage ? '/calendar' : null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/calendar', builder: (context, state) => const CalendarPage()),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
