import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_write.dart';
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

    try {
      final existing = await supabase
          .from(_table)
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (existing != null) return;
    } catch (_) {
      // Brak SELECT policy — spróbuj dopisać wiersz poniżej.
    }

    final metaName = user.userMetadata?['name'];
    final displayName = metaName is String && metaName.trim().isNotEmpty
        ? metaName.trim()
        : 'Użytkownik';

    try {
      await syncOwnProfileRow(
        userId: userId,
        fields: <String, dynamic>{'full_name': displayName},
      );
    } catch (_) {
      // RLS / trigger — koszyk może wymagać ręcznego dopięcia profilu w SQL.
    }
  }
}
