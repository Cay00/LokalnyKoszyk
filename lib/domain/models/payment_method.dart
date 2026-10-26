/// Placeholdery metod płatności (bez integracji bramki).
enum AppPaymentMethod {
  blik('BLIK'),
  cashOnPickup('Przy odbiorze'),
  bankTransfer('Przelew');

  const AppPaymentMethod(this.label);
  final String label;

  static const List<AppPaymentMethod> all = AppPaymentMethod.values;

  static AppPaymentMethod? tryParse(String raw) {
    final key = raw.trim().toLowerCase();
    for (final method in AppPaymentMethod.values) {
      if (method.name.toLowerCase() == key ||
          method.label.toLowerCase() == key) {
        return method;
      }
    }
    return null;
  }

  static List<AppPaymentMethod> parseList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return List.of(all);
    final parsed = raw
        .split(RegExp(r'[,;|]'))
        .map(tryParse)
        .whereType<AppPaymentMethod>()
        .toSet()
        .toList();
    return parsed.isEmpty ? List.of(all) : parsed;
  }

  static String encodeList(Iterable<AppPaymentMethod> methods) {
    return methods.map((m) => m.name).join(',');
  }
}
