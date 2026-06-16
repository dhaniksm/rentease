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

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl.isEmpty ? null : avatarUrl;

    if (updates.isNotEmpty) {
      await supabase.from('profiles').update(updates).eq('id', authUser.id);
    }
  }

  Future<String> uploadAvatar(dynamic file, String extension) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    final fileName = '${authUser.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filePath = 'public/$fileName';

    // Upload to 'avatars' bucket
    await supabase.storage.from('avatars').upload(
      filePath,
      file,
    );

    // Get public URL
    final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
    return imageUrl;
  }
}
