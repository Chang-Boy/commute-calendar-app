import 'package:commute_calendar/feature/user/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get authStateStream;
}
