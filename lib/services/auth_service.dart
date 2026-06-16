import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rentease/core/supabase_config.dart';

class AuthService {
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String phoneNumber = '',
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone_number': phoneNumber},
    );

    final user = response.user;
    if (user != null) {
      try {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'role': 'user', // Default is always user for security
        });
      } catch (e) {
        // Ignore error if profile is automatically created by a Supabase trigger or blocked by RLS
        debugPrint('Profile upsert ignored (likely handled by backend trigger): $e');
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }
}
