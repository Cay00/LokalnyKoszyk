/// PostgREST zwraca relację 1:1 czasem jako [Map], czasem jako [List] z jednym elementem.
Map<String, dynamic>? supabaseSingleEmbedded(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List) {
    for (final Object? item in value) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return Map<String, dynamic>.from(item);
    }
  }
  return null;
}

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
