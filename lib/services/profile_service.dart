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
        .single();

    return UserModel.fromJson({
      ...response,
      'email': response['email'] ?? authUser.email ?? '',
    });
  }
}
