import 'package:commute_calendar/feature/auth/data/datasources/auth_data_source.dart';
import 'package:commute_calendar/feature/auth/domain/repositories/i_auth_repository.dart';
import 'package:commute_calendar/feature/user/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      return await _dataSource.signIn(email, password);
    } catch (e) {
      throw Exception('로그인 중 오류가 발생했습니다: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _dataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> get authStateStream => _dataSource.authStateStream;
}
