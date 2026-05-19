import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rentease/core/supabase_config.dart';

class AuthService {

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {

    await supabase.auth.signUp(
      email: email,
      password: password,

      data: {
        'full_name': fullName,
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {

    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}