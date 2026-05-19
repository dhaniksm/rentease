import 'package:rentease/core/supabase_config.dart';
import 'package:rentease/models/user_model.dart';

class ProfileService {

  Future<UserModel> getProfile() async {

    final userId =
        supabase.auth.currentUser!.id;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }
}