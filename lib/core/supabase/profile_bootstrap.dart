import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Dopina brakujący wiersz w `public.profiles` dla użytkownika z Auth.
///
/// Tabele takie jak `carts` często mają FK `user_id` → `profiles(id)`.
/// Bez rekordu profilu insert koszyka kończy się błędem `23503`.
class ProfileBootstrap {
  ProfileBootstrap._();

  static const String _table = 'profiles';

  static Future<void> ensureRowForAuthUser(User user) async {
    final userId = user.id;
    if (userId.isEmpty) return;

    final existing = await supabase
        .from(_table)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (existing != null) return;

    final metaName = user.userMetadata?['name'];
    final displayName = metaName is String && metaName.trim().isNotEmpty
        ? metaName.trim()
        : _fallbackName(user.email);

    await supabase.from(_table).upsert(
      <String, dynamic>{
        'id': userId,
        'full_name': displayName,
      },
      onConflict: 'id',
    );
  }

  static String _fallbackName(String? email) {
    if (email == null || email.trim().isEmpty) return 'Użytkownik';
    final local = email.split('@').first.trim();
    return local.isEmpty ? 'Użytkownik' : local;
  }
}
