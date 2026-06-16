import 'package:commute_calendar/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:commute_calendar/feature/auth/presentation/sign_in/bloc/sign_in_event.dart';
import 'package:commute_calendar/feature/auth/presentation/sign_in/bloc/sign_in_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required SignInUseCase signIn})
    : _signIn = signIn,
      super(const SignInInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
  }

  final SignInUseCase _signIn;

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInLoading());
    try {
      await _signIn(event.email, event.password);
      emit(const SignInSuccess());
    } catch (e) {
      emit(SignInFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
