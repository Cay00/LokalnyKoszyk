/// Kwoty w Supabase jako liczba całkowita w groszach (np. 12,99 zł → 1299).
int parsePennies(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

double plnFromPennies(int grosze) => grosze / 100.0;

/// Tekst jak w [ProductData.price]: „12,99” (bez waluty).
String plnCommaStringFromPennies(int grosze) {
  return plnFromPennies(grosze).toStringAsFixed(2).replaceAll('.', ',');
}

/// Parsuje wpis użytkownika („12,99” / „12.99”) → grosze; `null` gdy niepoprawne.
int? penniesFromPlnInput(String text) {
  final normalized = text.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}
