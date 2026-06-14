import 'package:rentease/core/supabase_config.dart';
import 'package:rentease/models/user_model.dart';

class ProfileService {
  Future<UserModel> getProfile() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (response == null) {
      final defaultProfile = {
        'id': authUser.id,
        'full_name': authUser.email?.split('@')[0] ?? 'New User',
        'email': authUser.email ?? '',
        'phone_number': '',
        'role': 'user',
      };
      
      try {
        await supabase.from('profiles').upsert(defaultProfile);
      } catch (_) {
        // Abaikan jika gagal insert, kembalikan saja defaultnya
      }
      return UserModel.fromJson(defaultProfile);
    }

    return UserModel.fromJson({
      ...response,
      'email': response['email'] ?? authUser.email ?? '',
    });
  }
}
