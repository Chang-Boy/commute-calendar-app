import 'package:commute_calendar/feature/auth/domain/usecases/get_auth_state_stream_usecase.dart';
import 'package:commute_calendar/feature/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:commute_calendar/feature/auth/domain/usecases/sign_out_usecase.dart';
import 'package:commute_calendar/feature/auth/presentation/bloc/auth_event.dart';
import 'package:commute_calendar/feature/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required GetAuthStateStreamUseCase getAuthStateStream,
    required SignOutUseCase signOut,
  }) : _getCurrentUser = getCurrentUser,
       _getAuthStateStream = getAuthStateStream,
       _signOut = signOut,
       super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final GetAuthStateStreamUseCase _getAuthStateStream;
  final SignOutUseCase _signOut;

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }

    await emit.forEach(
      _getAuthStateStream(),
      onData: (user) =>
          user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      onError: (_, e) => const AuthUnauthenticated(),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut();
  }
}
