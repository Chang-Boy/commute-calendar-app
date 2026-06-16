import 'package:commute_calendar/feature/auth/domain/repositories/i_auth_repository.dart';
import 'package:commute_calendar/feature/user/domain/entities/user_entity.dart';

class GetAuthStateStreamUseCase {
  const GetAuthStateStreamUseCase(this._repository);

  final IAuthRepository _repository;

  Stream<UserEntity?> call() {
    return _repository.authStateStream;
  }
}
