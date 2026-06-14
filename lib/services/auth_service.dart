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
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'user', // Default is always user for security
      });
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
}
