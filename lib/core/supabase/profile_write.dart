import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

/// Zapis własnego wiersza w `public.profiles` (update, a gdy brak — insert).
///
/// Unika `upsert`, które w PostgREST wymaga polityki INSERT nawet przy UPDATE.
Future<void> syncOwnProfileRow({
  required String userId,
  required Map<String, dynamic> fields,
}) async {
  if (userId.isEmpty || fields.isEmpty) return;

  Future<bool> tryUpdate(Map<String, dynamic> payload) async {
    final updated = await supabase
        .from('profiles')
        .update(payload)
        .eq('id', userId)
        .select('id');
    return updated.isNotEmpty;
  }

  // Pełny zestaw pól (phone / default_address mogą jeszcze nie istnieć).
  try {
    if (await tryUpdate(fields)) return;
  } catch (_) {}

  // Minimalny zestaw — tylko full_name, jeśli jest.
  final fullName = fields['full_name'];
  if (fullName is String && fullName.trim().isNotEmpty) {
    try {
      if (await tryUpdate(<String, dynamic>{'full_name': fullName.trim()})) {
        return;
      }
    } catch (_) {}
  }

  // Brak wiersza → insert (wymaga polityki INSERT na profiles).
  try {
    await supabase.from('profiles').insert(<String, dynamic>{
      'id': userId,
      ...fields,
    });
    return;
  } catch (_) {}

  if (fullName is String && fullName.trim().isNotEmpty) {
    await supabase.from('profiles').insert(<String, dynamic>{
      'id': userId,
      'full_name': fullName.trim(),
    });
  }
}
