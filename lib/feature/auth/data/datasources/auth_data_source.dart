import 'package:commute_calendar/feature/user/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSource {
  final SupabaseClient _supabase;

  const AuthDataSource(this._supabase);

  Future<UserModel> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('로그인에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요.');
    }

    final data = await _supabase.from('users').select().eq('id', userId).single();
    return UserModel.fromJson(data);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return null;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', currentUser.id)
        .single();
    return UserModel.fromJson(data);
  }

  Stream<UserModel?> get authStateStream {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      if (data.event == AuthChangeEvent.signedIn && data.session?.user != null) {
        final userId = data.session!.user.id;
        final userData =
            await _supabase.from('users').select().eq('id', userId).single();
        return UserModel.fromJson(userData);
      }
      return null;
    });
  }
}
