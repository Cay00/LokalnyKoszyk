import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

/// Zwraca `sellers.id` powiązane z zalogowanym użytkownikiem albo `null`.
Future<String?> currentSellerId() async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null || userId.isEmpty) return null;
  try {
    final row = await supabase
        .from('sellers')
        .select('id')
        .eq('user_id', userId)
        .isFilter('deleted_at', null)
        .maybeSingle();
    final id = (row?['id'] ?? '').toString().trim();
    return id.isEmpty ? null : id;
  } catch (_) {
    return null;
  }
}
