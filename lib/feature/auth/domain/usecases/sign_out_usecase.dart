import 'package:commute_calendar/feature/auth/domain/repositories/i_auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> call() {
    return _repository.signOut();
  }
}
