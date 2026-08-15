enum ProductUnit {
  piece,
  kilogram,
  gram,
  liter,
  milliliter,
}

extension ProductUnitParsing on ProductUnit {
  static const Map<String, ProductUnit> _aliases = {
    'piece': ProductUnit.piece,
    'pieces': ProductUnit.piece,

    'kilogram': ProductUnit.kilogram,
    'kg': ProductUnit.kilogram,

    'gram': ProductUnit.gram,
    'g': ProductUnit.gram,

    'liter': ProductUnit.liter,
    'litre': ProductUnit.liter,
    'l': ProductUnit.liter,

    'milliliter': ProductUnit.milliliter,
    'millilitre': ProductUnit.milliliter,
    'ml': ProductUnit.milliliter,
  };

  static ProductUnit? fromSlashUnit(String slashUnit) {
    final normalized = slashUnit
        .replaceFirst(RegExp(r'^/\s*'), '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_');

    return _aliases[normalized];
  }
}

String formatAmountPl(num value) {
  final d = value.toDouble();

  if (_isWhole(d)) {
    return d.toInt().toString();
  }

  return d
      .toStringAsFixed(3)
      .replaceAll('.', ',')
      .replaceFirst(RegExp(r',?0+$'), '');
}

bool _isWhole(double value) {
  return value == value.roundToDouble();
}

bool _isOne(double value) {
  return (value - 1).abs() < 0.000001;
}

///
/// Przykłady:
///
/// 12,99 zł/szt.
/// 9,99 zł/2 szt.
/// 5,00 zł/kg
/// 3,49 zł/250 g
/// 7,99 zł/l
/// 4,99 zł/330 ml
///
///
/// Przykłady: `25 kg`, `2 szt.`, `250 g`, `330 ml`
///
String buildProductSizeLabel({
  required ProductUnit? unit,
  double? quantity,
  String fallback = '',
}) {
  final q = quantity;
  final hasQuantity = q != null && q > 0 && q.isFinite;

  if (unit == null) {
    return fallback.trim();
  }

  switch (unit) {
    case ProductUnit.piece:
      if (!hasQuantity) return 'szt.';
      return '${formatAmountPl(q)} szt.';

    case ProductUnit.kilogram:
      if (!hasQuantity) return 'kg';
      if (q < 1) {
        final grams = (q * 1000).round();
        return '$grams g';
      }
      return '${formatAmountPl(q)} kg';

    case ProductUnit.gram:
      if (!hasQuantity) return 'g';
      return '${formatAmountPl(q)} g';

    case ProductUnit.liter:
      if (!hasQuantity) return 'l';
      if (q < 1) {
        final ml = (q * 1000).round();
        return '$ml ml';
      }
      return '${formatAmountPl(q)} l';

    case ProductUnit.milliliter:
      if (!hasQuantity) return 'ml';
      return '${formatAmountPl(q)} ml';
  }
}

String buildProductPricePerLabel({
  required String priceFormatted,
  required ProductUnit? unit,
  double? quantity,
}) {
  final q = quantity;

  final hasQuantity = q != null && q > 0 && q.isFinite;

  if (unit == null) {
    return '$priceFormatted zł';
  }

  switch (unit) {
    case ProductUnit.piece:
      if (!hasQuantity || _isOne(q!)) {
        return '$priceFormatted zł/szt.';
      }

      return '$priceFormatted zł/${formatAmountPl(q)} szt.';

    case ProductUnit.kilogram:
      if (!hasQuantity || _isOne(q!)) {
        return '$priceFormatted zł/kg';
      }

      if (q < 1) {
        final grams = (q * 1000).round();
        return '$priceFormatted zł/$grams g';
      }

      return '$priceFormatted zł/${formatAmountPl(q)} kg';

    case ProductUnit.gram:
      if (!hasQuantity || _isOne(q!)) {
        return '$priceFormatted zł/g';
      }

      if (q < 1) {
        final mg = (q * 1000).round();
        return '$priceFormatted zł/$mg mg';
      }

      return '$priceFormatted zł/${formatAmountPl(q)} g';

    case ProductUnit.liter:
      if (!hasQuantity || _isOne(q!)) {
        return '$priceFormatted zł/l';
      }

      if (q < 1) {
        final ml = (q * 1000).round();
        return '$priceFormatted zł/$ml ml';
      }

      return '$priceFormatted zł/${formatAmountPl(q)} l';

    case ProductUnit.milliliter:
      if (!hasQuantity || _isOne(q!)) {
        return '$priceFormatted zł/ml';
      }

      return '$priceFormatted zł/${formatAmountPl(q)} ml';
  }
}
