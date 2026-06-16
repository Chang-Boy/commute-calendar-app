import 'package:commute_calendar/feature/auth/domain/repositories/i_auth_repository.dart';
import 'package:commute_calendar/feature/user/domain/entities/user_entity.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final IAuthRepository _repository;

  Future<UserEntity> call(String email, String password) {
    return _repository.signIn(email, password);
  }
}
