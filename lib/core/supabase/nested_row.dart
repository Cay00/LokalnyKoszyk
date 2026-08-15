/// Relacja 1:N albo pojedynczy embed — zawsze jako lista map (pusta gdy brak danych).
List<Map<String, dynamic>> supabaseEmbeddedMaps(dynamic value) {
  if (value == null) return const <Map<String, dynamic>>[];
  if (value is Map) {
    return <Map<String, dynamic>>[Map<String, dynamic>.from(value)];
  }
  if (value is List) {
    return value
        .whereType<Map>()
        .map((Map<dynamic, dynamic> m) => Map<String, dynamic>.from(m))
        .toList();
  }
  return const <Map<String, dynamic>>[];
}
