/// Parsuje cenę UI (`12,99` / `12.99`) do [double]; przy błędzie zwraca null.
double? parsePriceLabel(String? raw) {
  if (raw == null) return null;
  final cleaned = raw
      .trim()
      .replaceAll(RegExp(r'[^\d,.\-]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}
