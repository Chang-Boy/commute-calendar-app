import 'package:commute_calendar/feature/auth/domain/repositories/i_auth_repository.dart';
import 'package:commute_calendar/feature/user/domain/entities/user_entity.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final IAuthRepository _repository;

  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}
