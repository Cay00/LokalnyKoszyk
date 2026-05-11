/// Odczytuje klucz jednostki z pola [ProductData.unit] w formacie „/ piece”.
String? inferProductUnitKeyFromSlashUnit(String slashUnit) {
  final part = slashUnit
      .replaceFirst(RegExp(r'^/\s*'), '')
      .trim()
      .toLowerCase()
      .replaceAll(' ', '_');
  const known = <String>{
    'piece',
    'kilogram',
    'gram',
    'liter',
    'milliliter',
  };
  if (known.contains(part)) return part;
  return null;
}

String _formatAmountPl(num value) {
  final d = value.toDouble();
  if (d == d.roundToDouble()) {
    return d.toInt().toString();
  }
  var s = d.toStringAsFixed(3).replaceAll('.', ',');
  while (s.contains(',') && (s.endsWith('0') || s.endsWith(','))) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

/// Etykieta ceny zgodna z bazą: `12,99 zł/szt.`, `5,00 zł/litr`, `9,99 zł/100 mg` itd.
String buildProductPricePerLabel({
  required String priceFormatted,
  required String? unitKey,
  double? quantity,
}) {
  final key = unitKey?.trim().toLowerCase();
  if (key == null || key.isEmpty) {
    return '$priceFormatted zł';
  }

  final double? q = quantity;
  final bool hasQ = q != null && q > 0 && q.isFinite;

  switch (key) {
    case 'piece':
      if (!hasQ || q == 1) {
        return '$priceFormatted zł/szt.';
      }
      return '$priceFormatted zł/${_formatAmountPl(q)} szt.';

    case 'kilogram':
      if (!hasQ) return '$priceFormatted zł/kg';
      if (q < 1) {
        final grams = (q * 1000).round();
        return '$priceFormatted zł/$grams g';
      }
      return '$priceFormatted zł/${_formatAmountPl(q)} kg';

    case 'gram':
      if (!hasQ) return '$priceFormatted zł/g';
      if (q < 1) {
        final mg = (q * 1000).round();
        return '$priceFormatted zł/$mg mg';
      }
      return '$priceFormatted zł/${_formatAmountPl(q)} g';

    case 'liter':
      if (!hasQ || q == 1) {
        return '$priceFormatted zł/litr';
      }
      return '$priceFormatted zł/${_formatAmountPl(q)} l';

    case 'milliliter':
      if (!hasQ) return '$priceFormatted zł/ml';
      final mq = q;
      if (mq == mq.roundToDouble()) {
        return '$priceFormatted zł/${mq.round()} ml';
      }
      return '$priceFormatted zł/${_formatAmountPl(mq)} ml';

    default:
      return '$priceFormatted zł';
  }
}
